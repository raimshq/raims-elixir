"""Verify canonical Hex package bytes and publish stable releases through Hex."""
import argparse
import hashlib
import gzip
import io
import json
import os
from pathlib import Path
import re
import stat
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import zipfile

sys.dont_write_bytecode = True
REPOSITORY = 'raimshq/raims-elixir'
WORKFLOW = '.github/workflows/validate.yml'
JOBS = {'validateElixir': ('elixir-sdk-check', 'Run the canonical Elixir SDK checks'),
        'securityLinux': ('elixir-sdk-security', 'Run the canonical SDK security checks')}
RUNTIME_VERSIONS = {'1.18': {'elixir': '1.18.4', 'otp': '27.3.4.19'}, '1.19': {'elixir': '1.19.5', 'otp': '28.5.0.8'}}
HEX_VERSION = '2.6.0'
SHA = re.compile(r'[a-f0-9]{40}')
VERSION = re.compile(r'(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)')
MAX_DOWNLOAD = 32 * 1024 * 1024
MAX_METADATA = 2 * 1024 * 1024
FILES = {'raims.tar'}

def require(condition, message):
    if not condition:
        raise RuntimeError(message)

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, request, file, code, message, headers, new_url):
        return None

def read_response(request, maximum=MAX_METADATA):
    with urllib.request.build_opener(NoRedirect).open(request, timeout=60) as response:
        raw = response.read(maximum + 1)
        if response.headers.get('Content-Encoding') == 'gzip':
            require(len(raw) <= maximum, 'The compressed remote response exceeds the allowed size.')
            raw = gzip.decompress(raw)
    require(len(raw) <= maximum, 'The remote response exceeds the allowed size.')
    return raw

def public_download(url):
    parsed = urllib.parse.urlsplit(url)
    require(parsed.scheme == 'https' and parsed.hostname in {'github.com', 'hex.pm', 'repo.hex.pm'}
            and parsed.username is None and parsed.password is None, 'Unexpected public artifact origin.')
    request = urllib.request.Request(url, headers={'User-Agent': 'Raims-Elixir-Release'})
    try:
        return read_response(request, MAX_DOWNLOAD)
    except urllib.error.HTTPError as error:
        require(parsed.hostname == 'github.com' and error.code in {301, 302, 303, 307, 308},
                'A public artifact could not be read.')
        destination = error.headers.get('Location', '')
        redirect = urllib.parse.urlsplit(destination)
        require(redirect.scheme == 'https' and redirect.hostname == 'release-assets.githubusercontent.com'
                and redirect.username is None and redirect.password is None, 'Unexpected release download origin.')
        return read_response(urllib.request.Request(destination, headers={'User-Agent': 'Raims-Elixir-Release'}), MAX_DOWNLOAD)

def github_url(endpoint):
    return ('https://api.github.com/repos/' + REPOSITORY + '/' + endpoint).rstrip('/')

def github(endpoint, binary=False):
    token = os.environ.get('GITHUB_TOKEN')
    require(token, 'A GitHub token is required for release verification.')
    headers = {'Authorization': 'Bearer ' + token, 'Accept': 'application/vnd.github+json',
               'User-Agent': 'Raims-Elixir-Release', 'X-GitHub-Api-Version': '2022-11-28'}
    try:
        raw = read_response(urllib.request.Request(github_url(endpoint), headers=headers), MAX_DOWNLOAD if binary else MAX_METADATA)
    except urllib.error.HTTPError as error:
        require(binary and error.code in {301, 302, 303, 307, 308}, 'GitHub release metadata could not be read.')
        destination = error.headers.get('Location', '')
        url = urllib.parse.urlsplit(destination)
        require(url.scheme == 'https' and url.hostname and url.username is None and url.password is None and
                (url.hostname.endswith('.blob.core.windows.net') or url.hostname.endswith('.githubusercontent.com')
                 or url.hostname.endswith('.actions.githubusercontent.com')), 'Unexpected artifact download origin.')
        raw = read_response(urllib.request.Request(destination, headers={'User-Agent': 'Raims-Elixir-Release'}), MAX_DOWNLOAD)
    return raw if binary else json.loads(raw)

def git(source, *args):
    p = subprocess.run(['git', '-C', str(source), *args], capture_output=True, text=True, timeout=60)
    require(p.returncode == 0, 'Release source identity could not be verified.')
    return p.stdout.strip()

def source_version(source):
    project = (source / 'mix.exs').read_text(encoding='utf-8')
    versions = re.findall(r'^\s+version: "([^"]+)"', project, flags=re.M)
    require(len(versions) == 1 and VERSION.fullmatch(versions[0])
            and re.findall(r'^\s+app: :([a-z_]+),$', project, flags=re.M) == ['raims'],
            'A stable Hex package version and the official application are required.')
    core = (source / 'lib/raims.ex').read_text(encoding='utf-8')
    require(re.findall(r'^\s+@version "([^"]+)"', core, flags=re.M) == versions,
            'The declared SDK runtime and package versions differ.')
    return versions[0]


def context(source):
    require(os.environ.get('GITHUB_REPOSITORY') == REPOSITORY and os.environ.get('GITHUB_EVENT_NAME') == 'release',
            'Only the official repository release event may publish.')
    event = json.loads(Path(os.environ['GITHUB_EVENT_PATH']).read_text(encoding='utf-8'))
    release = event.get('release', {})
    require(event.get('action') == 'published' and release.get('draft') is False and release.get('prerelease') is False,
            'Only a published stable release can be uploaded.')
    version = source_version(source)
    tag = 'v' + version
    require(release.get('tag_name') == tag and os.environ.get('GITHUB_REF') == 'refs/tags/' + tag,
            'The release tag and Hex package version differ.')
    head = git(source, 'rev-parse', 'HEAD')
    require(SHA.fullmatch(head) and head == os.environ.get('GITHUB_SHA')
            and git(source, 'rev-parse', 'refs/tags/' + tag + '^{commit}') == head,
            'The checked-out release commit differs.')
    require(not git(source, 'status', '--porcelain', '--untracked-files=all'), 'Release sources must be clean.')
    repo = github('')
    require(repo.get('full_name') == REPOSITORY and repo.get('private') is False and repo.get('default_branch') == 'main',
            'The repository visibility or default branch differs.')
    require(github('commits/' + tag).get('sha') == head, 'The public tag changed.')
    git(source, 'merge-base', '--is-ancestor', head, 'origin/main')
    identifier = release.get('id')
    require(type(identifier) is int and identifier > 0, 'The release identity is invalid.')
    current = github('releases/' + str(identifier))
    require(current.get('id') == identifier and current.get('tag_name') == tag
            and current.get('draft') is False and current.get('prerelease') is False, 'The public release changed.')
    return {'sourceRevision': head, 'version': version, 'tag': tag, 'releaseId': identifier}

def validation(head, wait_seconds=600):
    deadline = time.monotonic() + wait_seconds
    while True:
        value = github('actions/workflows/validate.yml/runs?head_sha=' + head + '&per_page=100&page=1')
        rows = value.get('workflow_runs', [])
        require(isinstance(rows, list) and type(value.get('total_count')) is int, 'Validation history is incomplete.')
        if rows and rows[0].get('status') == 'completed':
            run = rows[0]
            break
        require(time.monotonic() < deadline, 'Validation of this exact commit did not finish within the allowed wait.')
        print('Waiting for validation of the release commit.', flush=True)
        time.sleep(min(15, max(0, deadline - time.monotonic())))
    require(run.get('head_sha') == head and run.get('path') == WORKFLOW and run.get('name') == 'Validate Elixir SDK'
            and run.get('conclusion') == 'success' and run.get('event') in {'push', 'workflow_dispatch'}
            and run.get('repository', {}).get('full_name') == REPOSITORY
            and run.get('head_repository', {}).get('full_name') == REPOSITORY,
            'Successful validation of this exact commit is required.')
    identifier, attempt = run.get('id'), run.get('run_attempt')
    require(type(identifier) is int and identifier > 0 and type(attempt) is int and attempt > 0,
            'Validation attempt identity is incomplete.')
    response = github(f'actions/runs/{identifier}/attempts/{attempt}/jobs?per_page=100&page=1')
    jobs = response.get('jobs', [])
    require(response.get('total_count') == len(jobs) == len(JOBS) and {job.get('name') for job in jobs} == set(JOBS),
            'The complete Elixir validation job inventory is required.')
    for job in jobs:
        suffix, step_name = JOBS[job['name']]
        require(job.get('status') == 'completed' and job.get('conclusion') == 'success'
                and set(job.get('labels', [])) == {f'codebuild-raims-github-actions-{identifier}-{attempt}', suffix}
                and len(job['labels']) == 2 and isinstance(job.get('runner_name'), str)
                and re.fullmatch(r'[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}', job['runner_name'])
                and job.get('runner_group_name'), 'A required AWS validation job did not pass.')
        required = [step for step in job.get('steps', []) if step.get('name') == step_name]
        require(len(required) == 1 and required[0].get('status') == 'completed' and required[0].get('conclusion') == 'success',
                'The canonical validation step did not pass.')
    return {'validationRunId': identifier, 'validationRunAttempt': attempt}

def artifact_files(value, proven):
    run, attempt = proven['validationRunId'], proven['validationRunAttempt']
    response = github(f'actions/runs/{run}/artifacts?per_page=100&page=1')
    require(type(response.get('total_count')) is int and 0 < response['total_count'] <= 100
            and isinstance(response.get('artifacts'), list) and len(response['artifacts']) == response['total_count'],
            'Validation artifact inventory is incomplete.')
    found = [row for row in response['artifacts'] if row.get('name') == f'raims-elixir-validation-{run}-{attempt}']
    require(len(found) == 1 and found[0].get('expired') is False
            and found[0].get('workflow_run', {}).get('id') == run
            and found[0].get('workflow_run', {}).get('head_sha') == value['sourceRevision'], 'The approved Hex package artifact is missing.')
    artifact = found[0]
    require(type(artifact.get('id')) is int and artifact['id'] > 0, 'The artifact identity is invalid.')
    raw = github('actions/artifacts/' + str(artifact['id']) + '/zip', binary=True)
    require(artifact.get('digest') == 'sha256:' + digest(raw), 'The Actions artifact digest differs.')
    with zipfile.ZipFile(io.BytesIO(raw)) as archive:
        expected = {'release-manifest.json', 'dist/raims.tar'}
        require(set(archive.namelist()) == expected and len(archive.infolist()) == len(expected)
                and sum(item.file_size for item in archive.infolist()) <= MAX_DOWNLOAD
                and all(not item.is_dir() and not stat.S_ISLNK(item.external_attr >> 16) for item in archive.infolist()),
                'The canonical Hex package artifact contains unexpected entries.')
        files = {'raims.tar': archive.read('dist/raims.tar')}
        manifest_raw = archive.read('release-manifest.json')
    manifest = json.loads(manifest_raw)
    require(set(manifest) == {'package', 'sourceRevision', 'toolkitRevision', 'runtimeVersions', 'hexVersion', 'files'}
            and manifest['package'] == {'name': 'raims', 'version': value['version']}
            and manifest['sourceRevision'] == value['sourceRevision']
            and manifest['toolkitRevision'] == os.environ.get('RAIMS_ELIXIR_TOOLKIT_REF')
            and SHA.fullmatch(str(manifest['toolkitRevision']))
            and manifest['runtimeVersions'] == RUNTIME_VERSIONS and manifest['hexVersion'] == HEX_VERSION
            and manifest['files'] == {name: digest(raw) for name, raw in files.items()},
            'The canonical report and Hex package bytes differ.')
    files['release-manifest.json'] = manifest_raw
    return files, artifact['id']

def upload_release_asset(identifier, name, raw):
    token = os.environ.get('GITHUB_TOKEN')
    require(token and type(identifier) is int and identifier > 0 and Path(name).name == name, 'An asset upload could not be authorized.')
    endpoint = 'https://uploads.github.com/repos/' + REPOSITORY + '/releases/' + str(identifier) + '/assets?name=' + urllib.parse.quote(name, safe='')
    request = urllib.request.Request(endpoint, data=raw, method='POST', headers={'Authorization': 'Bearer ' + token,
        'Content-Type': 'application/octet-stream', 'User-Agent': 'Raims-Elixir-Release', 'Accept': 'application/vnd.github+json'})
    try:
        read_response(request)
    except (OSError, RuntimeError):
        current = github('releases/' + str(identifier))
        existing = [asset for asset in current.get('assets', []) if asset.get('name') == name]
        require(len(existing) == 1 and public_download(existing[0]['browser_download_url']) == raw,
                'Release asset creation was not confirmed; inspect the release before retrying.')

def release_files(value, files, create_missing=False):
    rows = github('releases/' + str(value['releaseId'])).get('assets', [])
    assets = {asset['name']: asset for asset in rows}
    expected = set(files) | {'SHA256SUMS'}
    require(len(assets) == len(rows) and set(assets).issubset(expected), 'The release contains unexpected or duplicate assets.')
    complete = dict(files, SHA256SUMS=''.join(digest(files[name]) + '  ' + name + '\n' for name in sorted(files)).encode())
    for name, raw in complete.items():
        if name in assets:
            require(public_download(assets[name]['browser_download_url']) == raw, 'An existing release asset differs from approved CI bytes.')
    missing = set(complete) - set(assets)
    require(not missing or create_missing, 'The approved Hex package assets are missing from the release.')
    for name in sorted(missing):
        upload_release_asset(value['releaseId'], name, complete[name])
    if missing:
        rows = github('releases/' + str(value['releaseId'])).get('assets', [])
        assets = {asset['name']: asset for asset in rows}
    require(len(assets) == len(rows) and set(assets) == expected, 'The release asset inventory differs.')
    for name, raw in complete.items():
        require(public_download(assets[name]['browser_download_url']) == raw, 'A public release asset differs.')

def indexed(version, raw):
    endpoint = 'https://hex.pm/api/packages/raims/releases/' + version
    try:
        metadata = json.loads(read_response(urllib.request.Request(endpoint, headers={
            'User-Agent': 'Raims-Elixir-Release', 'Cache-Control': 'no-cache', 'Accept-Encoding': 'gzip'})))
    except urllib.error.HTTPError as error:
        if error.code == 404:
            return None
        raise RuntimeError('Public Hex version metadata could not be read.') from None
    require(metadata.get('version') == version and metadata.get('checksum') == digest(raw)
            and metadata.get('meta') == {'app': 'raims', 'elixir': '~> 1.18', 'build_tools': ['mix']}
            and metadata.get('retirement') is None
            and metadata.get('requirements') == {'mint': {'app': 'mint', 'optional': False, 'requirement': '~> 1.11.0'}},
            'An existing Hex version differs from the approved identity, requirements or bytes.')
    package = json.loads(read_response(urllib.request.Request('https://hex.pm/api/packages/raims',
        headers={'User-Agent': 'Raims-Elixir-Release', 'Cache-Control': 'no-cache', 'Accept-Encoding': 'gzip'})))
    require(package.get('name') == 'raims' and package.get('repository') == 'hexpm'
            and package.get('meta', {}).get('links', {}).get('GitHub') == 'https://github.com/' + REPOSITORY,
            'The Hex package is not linked to the official SDK repository.')
    require(public_download('https://repo.hex.pm/tarballs/raims-' + version + '.tar') == raw,
            'The public Hex tarball differs from the approved bytes.')
    return metadata


def validate_local(artifact, files):
    require(artifact.is_dir() and not artifact.is_symlink(), 'The approved upload directory is missing.')
    paths = list(artifact.rglob('*'))
    require({path.relative_to(artifact).as_posix() for path in paths} == {'dist', 'dist/raims.tar', 'release-manifest.json'}
            and all(not path.is_symlink() for path in paths), 'The upload directory contains unexpected entries.')
    for name, raw in files.items():
        path = artifact / name if name == 'release-manifest.json' else artifact / 'dist' / name
        require(path.read_bytes() == raw, 'The local Hex package upload differs from approved CI bytes.')

def staged_response(response, value, raw):
    expected_url = 'https://hex.pm/api/packages/raims/releases/' + value['version'] + '/staged'
    expected_html = 'https://hex.pm/dashboard/staged-releases/hexpm/raims/' + value['version']
    require(isinstance(response, dict) and response.get('name') == 'raims'
            and response.get('version') == value['version'] and response.get('kind') == 'release'
            and response.get('status') in {'staged', 'approved', 'rejected', 'expired'}
            and response.get('checksum') == digest(raw)
            and re.fullmatch(r'[a-f0-9]{64}', str(response.get('approval_checksum')))
            and response.get('url') == expected_url and response.get('html_url') == expected_html,
            'An existing staged release differs from the approved identity or bytes.')
    require(response['status'] not in {'rejected', 'expired'},
            'The staged release was rejected or expired; an owner must review it before another upload.')
    return response


def prior_stage(authorization, value, raw):
    endpoint = 'https://hex.pm/api/packages/raims/releases/' + value['version'] + '/staged'
    request = urllib.request.Request(endpoint, headers={'Authorization': authorization,
        'User-Agent': 'Raims-Elixir-Release', 'Accept': 'application/json'})
    try:
        response = json.loads(read_response(request))
    except urllib.error.HTTPError as error:
        if error.code == 404:
            return None
        raise RuntimeError('Existing staged Hex publication could not be inspected.') from None
    return staged_response(response, value, raw)


def publish(artifact, value, files):
    raw = files['raims.tar']
    if indexed(value['version'], raw):
        print('The exact approved Hex package is already published; no upload is required.', flush=True)
        return
    token = os.environ.get('HEX_PUBLISH_TOKEN', '')
    require(bool(token) and '\r' not in token and '\n' not in token,
            'A short-lived scoped Hex publishing credential is required.')
    authorization = 'Bearer ' + token
    staged = prior_stage(authorization, value, raw)
    if staged is None:
        request = urllib.request.Request('https://hex.pm/api/packages/raims/releases?replace=false',
            data=raw, method='POST', headers={'Authorization': authorization,
            'Content-Type': 'application/octet-stream', 'Accept': 'application/json',
            'User-Agent': 'Raims-Elixir-Release'})
        try:
            response = json.loads(read_response(request))
        except (OSError, RuntimeError, ValueError):
            # Never repeat an uncertain write. Read public/staged state first.
            if indexed(value['version'], raw):
                confirm(value['version'], files, value=value, require_oidc=True)
                return
            staged = prior_stage(authorization, value, raw)
            require(staged is not None,
                    'Hex upload was not confirmed; inspect the registry before retrying.')
        else:
            if response.get('status') == 'staged':
                staged = staged_response(response, value, raw)
            else:
                require(response.get('version') == value['version'] and response.get('checksum') == digest(raw),
                        'Hex did not confirm the approved package identity.')
    if staged is not None:
        state = artifact.parent / 'hex-staged-release.json'
        state.write_text(json.dumps(staged, indent=2) + '\n', encoding='utf-8')
        print('Hex requires owner approval of the exact tarball. The upload is staged, not public.', flush=True)
        print('Expected package checksum: ' + digest(raw), flush=True)
        print('Approval: ' + staged['html_url'], flush=True)
    confirm(value['version'], files, value=value, require_oidc=True)


def confirm(version, files, wait_seconds=600, value=None, require_oidc=False):
    deadline = time.monotonic() + wait_seconds
    while True:
        metadata = indexed(version, files['raims.tar'])
        if metadata:
            if require_oidc:
                claims = metadata.get('oidc_claims')
                require(isinstance(claims, dict) and claims.get('repository') == REPOSITORY
                        and claims.get('sha') == value['sourceRevision']
                        and claims.get('workflow_ref') == REPOSITORY + '/.github/workflows/hex-release.yml@refs/tags/v' + version
                        and str(claims.get('run_id')) == os.environ.get('GITHUB_RUN_ID')
                        and str(claims.get('run_attempt')) == os.environ.get('GITHUB_RUN_ATTEMPT'),
                        'The public Hex provenance does not match this OIDC publication.')
            print('Hex serves the exact approved package bytes.', flush=True)
            return
        require(time.monotonic() < deadline,
                'Hex has not confirmed public package bytes; inspect staged approval before retrying.')
        time.sleep(min(10, max(0, deadline - time.monotonic())))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=('prepare', 'verify', 'publish', 'confirm'))
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--artifact', type=Path, required=True)
    args = parser.parse_args()
    source, artifact = args.source.resolve(), args.artifact.resolve()
    workspace = Path(os.environ.get('GITHUB_WORKSPACE', '.')).resolve()
    require(workspace / '.tmp' in artifact.parents, 'Release artifacts must stay in workspace .tmp.')
    value = context(source)
    proven = validation(value['sourceRevision'])
    files, _identifier = artifact_files(value, proven)
    release_files(value, files, create_missing=args.command == 'prepare')
    if args.command == 'prepare':
        require(not artifact.exists(), 'Use a new upload directory.')
        (artifact / 'dist').mkdir(parents=True)
        for name, raw in files.items():
            (artifact / name if name == 'release-manifest.json' else artifact / 'dist' / name).write_bytes(raw)
    else:
        validate_local(artifact, files)
    if args.command == 'verify':
        required = not indexed(value['version'], files['raims.tar'])
        if os.environ.get('GITHUB_OUTPUT'):
            with Path(os.environ['GITHUB_OUTPUT']).open('a', encoding='utf-8') as output:
                output.write('publishRequired=' + ('true' if required else 'false') + '\n')
    elif args.command == 'publish':
        publish(artifact, value, files)
    elif args.command == 'confirm':
        confirm(value['version'], files)
    return 0

if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError, zipfile.BadZipFile) as error:
        print('Elixir release verification failed: ' + str(error), file=sys.stderr)
        sys.exit(1)
