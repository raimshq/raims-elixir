# Elixir SDK reference

Generated from the published public contract pinned in `contracts/source.json`.

Create a `Raims.Client` and pass it to a resource module. Resource functions return
`{:ok, %Raims.Response{}}` or `{:error, %Raims.Error{}}`. Their `!` variants return
the response or raise the same structured error. Invalid local arguments raise
`ArgumentError` before sending HTTP.

Methods accept path IDs first, then a parameter map and keyword request options.
Read fields with `response.data["field"]` or the generated model getters.

| Function | HTTP operation | Input | Response data |
| --- | --- | --- | --- |
| `Raims.Accounts.retrieve_fees` | `GET /v1/accounts/fees` | - | `Raims.Models.AccountFees.t()` |
| `Raims.Accounts.retrieve_number` | `GET /v1/accounts/account_number` | - | `Raims.Models.AccountNumber.t()` |
| `Raims.Accounts.retrieve_checkout_settings` | `GET /v1/accounts/checkout_settings` | - | `Raims.Models.CheckoutSettings.t()` |
| `Raims.Accounts.update_checkout_settings` | `PATCH /v1/accounts/checkout_settings` | [`UpdateCheckoutSettingsParams`](#updatecheckoutsettingsparams) | `Raims.Models.CheckoutSettings.t()` |
| `Raims.Accounts.create_checkout_logo_upload` | `POST /v1/accounts/checkout_settings/logo_uploads` | [`CreateCheckoutLogoUploadParams`](#createcheckoutlogouploadparams) | `Raims.Models.CheckoutAssetUpload.t()` |
| `Raims.Accounts.create_checkout_favicon_upload` | `POST /v1/accounts/checkout_settings/favicon_uploads` | [`CreateCheckoutFaviconUploadParams`](#createcheckoutfaviconuploadparams) | `Raims.Models.CheckoutAssetUpload.t()` |
| `Raims.Accounts.delete_checkout_asset_upload` | `DELETE /v1/accounts/checkout_settings/uploads/{id}` | - | `Raims.Models.CheckoutAssetUploadDeleted.t()` |
| `Raims.Accounts.retrieve_context` | `GET /v1/accounts/context` | - | `Raims.Models.AccountContext.t()` |
| `Raims.Balances.retrieve` | `GET /v1/balances` | - | `Raims.Models.Balance.t()` |
| `Raims.Balances.forecast` | `GET /v1/balances/forecast` | [`GetBalanceForecastParams`](#getbalanceforecastparams) | `Raims.Models.BalanceForecast.t()` |
| `Raims.Charges.create` | `POST /v1/charges` | [`CreateChargeParams`](#createchargeparams) | `Raims.Models.ChargeCreated.t()` |
| `Raims.Charges.list` | `GET /v1/charges` | [`ListChargesParams`](#listchargesparams) | `Raims.Models.ChargeListResponse.t()` |
| `Raims.Charges.retrieve` | `GET /v1/charges/{id}` | - | `Raims.Models.Charge.t()` |
| `Raims.Charges.update` | `PATCH /v1/charges/{id}` | [`UpdateChargeParams`](#updatechargeparams) | `Raims.Models.Charge.t()` |
| `Raims.Charges.revoke` | `DELETE /v1/charges/{id}` | - | `Raims.Models.ChargeRevoked.t() \| Raims.Models.ChargeRevocationPending.t()` |
| `Raims.Charges.retrieve_payment` | `GET /v1/charges/{id}/payment` | - | `Raims.Models.PaymentReceipt.t()` |
| `Raims.Charges.retrieve_receipt` | `GET /v1/charges/{id}/receipt` | - | `Raims.Models.FinancialDocument.t()` |
| `Raims.Charges.retrieve_boleto` | `GET /v1/charges/{id}/boleto` | - | `Raims.Models.FinancialDocument.t()` |
| `Raims.Charges.create_refund` | `POST /v1/charges/{id}/refunds` | [`CreateRefundParams`](#createrefundparams) | `Raims.Models.Refund.t()` |
| `Raims.Charges.list_refunds` | `GET /v1/charges/{id}/refunds` | [`ListChargeRefundsParams`](#listchargerefundsparams) | `Raims.Models.RefundListResponse.t()` |
| `Raims.Charges.retrieve_refund_eligibility` | `GET /v1/charges/{id}/refund_eligibility` | - | `Raims.Models.RefundEligibility.t()` |
| `Raims.Charges.statistics` | `GET /v1/charges/statistics` | [`GetChargeStatisticsParams`](#getchargestatisticsparams) | `Raims.Models.ChargeStatistics.t()` |
| `Raims.Customers.create` | `POST /v1/customers` | [`CreateCustomerParams`](#createcustomerparams) | `Raims.Models.CustomerCreated.t()` |
| `Raims.Customers.list` | `GET /v1/customers` | [`ListCustomersParams`](#listcustomersparams) | `Raims.Models.CustomerListResponse.t()` |
| `Raims.Customers.retrieve` | `GET /v1/customers/{id}` | - | `Raims.Models.CustomerListItem.t()` |
| `Raims.Customers.update` | `PATCH /v1/customers/{id}` | [`UpdateCustomerParams`](#updatecustomerparams) | `Raims.Models.CustomerListItem.t()` |
| `Raims.Customers.delete` | `DELETE /v1/customers/{id}` | - | `Raims.Models.CustomerDeleted.t()` |
| `Raims.Customers.delete_batch` | `DELETE /v1/customers` | [`DeleteCustomersBatchParams`](#deletecustomersbatchparams) | `Raims.Models.CustomerBatchDeleted.t()` |
| `Raims.Disputes.list` | `GET /v1/disputes` | [`ListDisputesParams`](#listdisputesparams) | `Raims.Models.DisputeListResponse.t()` |
| `Raims.Disputes.retrieve` | `GET /v1/disputes/{id}` | - | `Raims.Models.Dispute.t()` |
| `Raims.PaymentLinks.create` | `POST /v1/payment_links` | [`CreatePaymentLinkParams`](#createpaymentlinkparams) | `Raims.Models.PaymentLink.t()` |
| `Raims.PaymentLinks.list` | `GET /v1/payment_links` | [`ListPaymentLinksParams`](#listpaymentlinksparams) | `Raims.Models.PaymentLinkListResponse.t()` |
| `Raims.PaymentLinks.retrieve` | `GET /v1/payment_links/{id}` | - | `Raims.Models.PaymentLinkDetails.t()` |
| `Raims.PaymentLinks.update` | `PATCH /v1/payment_links/{id}` | [`UpdatePaymentLinkParams`](#updatepaymentlinkparams) | `Raims.Models.PaymentLink.t()` |
| `Raims.PaymentLinks.send_email` | `POST /v1/payment_links/{id}/send_email` | - | `Raims.Models.PaymentLinkEmailRequestAccepted.t()` |
| `Raims.Refunds.list` | `GET /v1/refunds` | [`ListRefundsParams`](#listrefundsparams) | `Raims.Models.RefundListResponse.t()` |
| `Raims.Refunds.retrieve` | `GET /v1/refunds/{id}` | - | `Raims.Models.Refund.t()` |
| `Raims.Refunds.retrieve_receipt` | `GET /v1/refunds/{id}/receipt` | - | `Raims.Models.FinancialDocument.t()` |
| `Raims.Statements.list` | `GET /v1/statements` | [`ListStatementsParams`](#liststatementsparams) | `Raims.Models.StatementListResponse.t()` |
| `Raims.Statements.retrieve` | `GET /v1/statements/{id}` | - | `Raims.Models.Statement.t()` |
| `Raims.WebhookEventTypes.list` | `GET /v1/webhook_event_types` | - | `Raims.Models.WebhookEventTypeListResponse.t()` |
| `Raims.Webhooks.create` | `POST /v1/webhooks` | [`CreateWebhookParams`](#createwebhookparams) | `Raims.Models.WebhookCreated.t()` |
| `Raims.Webhooks.list` | `GET /v1/webhooks` | [`ListWebhooksParams`](#listwebhooksparams) | `Raims.Models.WebhookListResponse.t()` |
| `Raims.Webhooks.retrieve` | `GET /v1/webhooks/{webhook_id}` | - | `Raims.Models.Webhook.t()` |
| `Raims.Webhooks.update` | `PATCH /v1/webhooks/{webhook_id}` | [`UpdateWebhookParams`](#updatewebhookparams) | `Raims.Models.Webhook.t()` |
| `Raims.Webhooks.delete` | `DELETE /v1/webhooks/{webhook_id}` | - | `nil` |
| `Raims.Webhooks.retrieve_health` | `GET /v1/webhooks/{webhook_id}/health` | - | `Raims.Models.WebhookHealth.t()` |
| `Raims.Webhooks.set_pause` | `PATCH /v1/webhooks/{webhook_id}/pause` | [`SetWebhookPauseParams`](#setwebhookpauseparams) | `Raims.Models.WebhookPause.t()` |
| `Raims.Webhooks.rotate_secret` | `POST /v1/webhooks/{webhook_id}/rotate_secret` | [`RotateWebhookSecretParams`](#rotatewebhooksecretparams) | `Raims.Models.WebhookSecretRotation.t()` |
| `Raims.Webhooks.test` | `POST /v1/webhooks/{webhook_id}/test` | - | `Raims.Models.WebhookTestAccepted.t()` |
| `Raims.WithdrawalDestinations.list` | `GET /v1/withdrawal_destinations` | [`ListWithdrawalDestinationsParams`](#listwithdrawaldestinationsparams) | `Raims.Models.WithdrawalDestinationListResponse.t()` |
| `Raims.WithdrawalDestinations.retrieve` | `GET /v1/withdrawal_destinations/{id}` | - | `Raims.Models.WithdrawalDestination.t()` |
| `Raims.Withdrawals.create` | `POST /v1/withdrawals` | [`CreateWithdrawalParams`](#createwithdrawalparams) | `Raims.Models.Withdrawal.t()` |
| `Raims.Withdrawals.list` | `GET /v1/withdrawals` | [`ListWithdrawalsParams`](#listwithdrawalsparams) | `Raims.Models.WithdrawalListResponse.t()` |
| `Raims.Withdrawals.retrieve` | `GET /v1/withdrawals/{id}` | - | `Raims.Models.Withdrawal.t()` |
| `Raims.Withdrawals.retrieve_limits` | `GET /v1/withdrawals/limits` | - | `Raims.Models.WithdrawalLimits.t()` |
| `Raims.Withdrawals.retrieve_summary` | `GET /v1/withdrawals/summary` | - | `Raims.Models.WithdrawalSummary.t()` |
| `Raims.Withdrawals.retrieve_automatic_settings` | `GET /v1/withdrawals/automatic_settings` | - | `Raims.Models.AutomaticWithdrawalSettings.t()` |
| `Raims.Withdrawals.update_automatic_settings` | `PATCH /v1/withdrawals/automatic_settings` | [`UpdateAutomaticWithdrawalSettingsParams`](#updateautomaticwithdrawalsettingsparams) | `Raims.Models.AutomaticWithdrawalSettings.t()` |
| `Raims.Simulations.Charges.confirm_payment` | `POST /v1/simulations/charges/{id}/confirm_payment` | - | `Raims.Models.ChargeSimulation.t()` |
| `Raims.Simulations.Charges.fail_payment` | `POST /v1/simulations/charges/{id}/fail_payment` | - | `Raims.Models.ChargeSimulation.t()` |
| `Raims.Simulations.Charges.configure_scenario` | `POST /v1/simulations/charges/{id}/scenario` | [`ConfigureSimulationScenarioParams`](#configuresimulationscenarioparams) | `Raims.Models.ChargeScenario.t()` |
| `Raims.Simulations.Charges.resolve_scenario` | `POST /v1/simulations/charges/{id}/resolve` | [`ResolveSimulationScenarioParams`](#resolvesimulationscenarioparams) | `Raims.Models.ChargeScenario.t()` |
| `Raims.Simulations.Charges.issue_payment` | `POST /v1/simulations/charges/{id}/issue_payment` | [`IssueSimulationPaymentParams`](#issuesimulationpaymentparams) | `Raims.Models.Charge.t()` |
| `Raims.Simulations.Charges.compensate_boleto` | `POST /v1/simulations/charges/{id}/compensate_boleto` | - | `Raims.Models.ChargeBoletoCompensation.t()` |
| `Raims.Simulations.Charges.create_refund` | `POST /v1/simulations/charges/{id}/refunds` | [`CreateSimulationRefundParams`](#createsimulationrefundparams) | `Raims.Models.Refund.t()` |
| `Raims.Simulations.Refunds.complete` | `POST /v1/simulations/refunds/{id}/complete` | - | `Raims.Models.Refund.t()` |
| `Raims.Simulations.Refunds.fail` | `POST /v1/simulations/refunds/{id}/fail` | - | `Raims.Models.Refund.t()` |

Parameters are maps using the API's JSON names as string or atom keys. An omitted
key and an explicit `nil` are distinct. Monetary amounts use integer cents;
resource dates use UTC Unix seconds. Responses preserve future fields and values.
HTTP `202` is pending. Use the relevant retrieval function to follow its result.

## Input parameters

The names below identify parameter maps, not separate request structs. The SDK
checks declared schema constraints before HTTP; the API enforces business rules.

### UpdateChargeParams

Update an existing charge.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `title` | `String.t() \| nil` | No | Charge title. Omit it to keep the current title; send null or empty text to remove it. |
| `description` | `String.t() \| nil` | No | Charge description. Omit it to keep the current description; send null or empty text to remove it. |
| `external_reference` | `String.t() \| nil` | No | Order or charge reference in your system. Omit it to keep the current value; send null or empty text to remove it. It may be repeated on other charges and is independent of the customer reference. |
| `metadata` | `map() \| nil` | No | Integration data associated with the resource. Supply key and text pairs. Keys are case-sensitive. Omission or {} preserves the data; null removes all pairs, and null for a key removes only that key. Empty text is a valid value. |

### ListChargesParams

List charges.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `integer()` | No | Charges per page. Positive integers above the maximum use the maximum. Omitted, empty, zero, negative, or invalid values use 10. |
| `after` | `String.t()` | No | Copy page.next_after from the previous response to move forward. Keep the same filters and sort order; do not send before as well. Leave it empty to start the list. |
| `before` | `String.t()` | No | Copy page.previous_before from the previous response to move backward. Keep the same filters and sort order; do not send after as well. Leave it empty if you do not want to go backward. |
| `identifier` | `String.t()` | No | Filter by the complete charge ID. If there is no match, list is empty. |
| `customer_id` | `String.t()` | No | Filter by the customer's complete public ID returned when creating or retrieving the customer. The relationship remains unchanged if the name or email changes. It can be combined with other filters; keep the same customer_id when changing pages. A valid ID with no charges in the authenticated company and environment returns an empty list. An empty or omitted value does not apply the filter. |
| `external_reference` | `String.t()` | No | Filter by the charge's current reference in your system, matching the complete value, including case and accents. An empty or omitted value does not apply the filter. It can be combined with other filters; preserve the value when navigating by cursor. After creating or editing a charge, it may take a few seconds for search to reflect the reference. |
| `email` | `String.t()` | No | Filter by the complete email address recorded on the charge. Editing the customer record does not change that email address. |
| `status` | `String.t()` | No | Filter by one or more comma-separated codes, such as 0,1. 0 created, 1 awaiting payment, 2 authorized, 3 processing, 4 paid, 5 partially refunded, 6 refunded, 7 cancelled, 8 expired, 9 failed, 10 chargeback, 11 chargeback under review, 12 chargeback lost, and 13 chargeback won. Changes may take a few seconds to appear. |
| `payment_method` | `String.t()` | No | Filter by the charge's payment method: 1 for Pix and 2 for boleto. To combine them, send 1,2. A charge with an undefined method may switch to Pix or boleto when the Pix code or boleto is generated in checkout. Selecting a method on the page alone does not change the filter. |
| `created_gte` | `integer()` | No | Filter charges created at or after this instant, inclusive, in Unix seconds UTC. If created_lte is supplied, this value must be less than or equal to it. |
| `created_lte` | `integer()` | No | Filter charges created at or before this instant, inclusive, in Unix seconds UTC. |
| `due_gte` | `integer()` | No | Filter charges due at or after this instant, inclusive, in Unix seconds UTC. It can be combined with due_lte and other filters; preserve the value when changing pages. |
| `due_lte` | `integer()` | No | Filter charges due at or before this instant, inclusive, in Unix seconds UTC. If due_gte is supplied, this value must be greater than or equal to it. It can be used alone or with other filters. |
| `paid_gte` | `integer()` | No | Filter charges paid at or after this instant, inclusive, in Unix seconds UTC. Uses the confirmed payment date, even if a refund occurred later. Charges without a confirmed payment are excluded. Preserve the value when changing pages. |
| `paid_lte` | `integer()` | No | Filter charges paid at or before this instant, inclusive, in Unix seconds UTC. If paid_gte is supplied, this value must be greater than or equal to it. It can be combined with other filters. |
| `sort_key` | `String.t()` | No | Sort by the amount in cents or creation date. If omitted, uses registration order; with a creation-date filter, uses created_at. Keep the same sort order when changing pages. |
| `sort_order` | `String.t()` | No | Set the sort direction. With desc, the default order shows the newest charges first. |

### CreateChargeParams

Create a new charge.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `customer_id` | `String.t()` | Yes | ID of a customer in the authenticated company and environment. Copy the id returned when creating or retrieving the customer. Direct Pix requires a valid CPF/CNPJ. Direct boleto requires a name, valid email address, CPF/CNPJ, and address including CEP and street number; complete those fields on the customer record. |
| `amount_cents` | `integer()` | Yes | Charge amount in Brazilian real cents. For example, 10000 represents BRL 100.00. |
| `payment_method` | `0 \| 1 \| 2` | No | Charge payment method. Omit it or send 0 to allow selection in checkout. Without payment_method_types, 1 requests Pix and 2 requests boleto at creation, subject to enabled methods. Boleto uses the customer's address and fills missing fields from the CEP when available. With a custom list, send 0 or omit this field; issuance occurs after the checkout selection. |
| `due_date` | `integer()` | Yes | Due date in Unix seconds UTC, at least five minutes in the future. The latest date is today plus ten years, using the São Paulo calendar. |
| `title` | `String.t() \| nil` | No | Charge title. You may leave this field empty. |
| `description` | `String.t() \| nil` | No | Charge description. You may leave this field empty. |
| `send_email` | `boolean()` | No | With true, requests delivery of the charge to the customer's email address and generates checkout_url. For pending accounts, the customer must use the account's primary email address. Outside that condition, a missing or invalid email prevents delivery but still allows charge creation when there is no direct boleto issuance. Direct boleto requires a valid email even with false. The response does not confirm message delivery. |
| `create_checkout` | `boolean()` | No | With true, generates the link returned in checkout_url without requiring a return URL or requesting email delivery. With false, the link is still generated when send_email is true or a return URL is supplied. |
| `success_redirect_url` | `String.t() \| nil` | No | HTTPS URL on your website for returning after confirmed payment. Redirection does not prove payment; retrieve the charge to confirm it. Credentials in the address, literal IPs, localhost, and Raims domains are not accepted. When supplied, generates checkout_url even with send_email false. If omitted, empty, or null, no return destination is set. |
| `cancel_redirect_url` | `String.t() \| nil` | No | HTTPS URL on your website for the payer to return from checkout. Returning does not cancel the charge, Pix, or boleto. Credentials in the address, literal IPs, localhost, and Raims domains are not accepted. When supplied, generates checkout_url even with send_email false. If omitted, empty, or null, no return destination is set. |
| `payment_method_types` | `[1 \| 2] \| nil` | No | Allowed methods for the charge: 1 for Pix and 2 for boleto. Omission or null uses the inherited checkout settings. Supply a list without duplicates. A custom configuration replaces the account default; a link configuration can only restrict that list. Combine with payment_method omitted or set to 0. |
| `external_reference` | `String.t() \| nil` | No | Order or charge reference in your system. Null, empty text, or whitespace leaves it without a reference. It may be repeated and does not prevent duplicate charges. It differs from the reference on the customer record. |
| `metadata` | `map() \| nil` | No | Integration data associated with the charge, as key and text pairs. Keys are case-sensitive. Omission, null, or {} creates the charge without this data; pairs with a null value are not included. Empty text is a valid value. |

### CreateCustomerParams

Create a customer.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `full_name` | `String.t() \| nil` | No | Payer's full name. |
| `tax_id` | `String.t()` | Yes | Valid CPF or CNPJ, with or without periods, slash, hyphen, and spaces. |
| `email` | `String.t() \| nil` | No | Payer's email address. Recording an email address does not send a message. |
| `dial_code` | `String.t() \| nil` | No | International dialing code. It may be supplied without phone_local. |
| `phone_local` | `String.t() \| nil` | No | Phone number without the dialing code, with or without punctuation. It may be supplied without dial_code. |
| `zip_code` | `String.t() \| nil` | No | Address CEP, with or without a hyphen. If street, neigh, city, uf, street_number, and complement are empty, the CEP may populate street, neighborhood, city, and state. It does not populate the street number or address complement. |
| `street` | `String.t() \| nil` | No | Address street. |
| `street_number` | `String.t() \| nil` | No | Address street number. |
| `complement` | `String.t() \| nil` | No | Address complement. |
| `neigh` | `String.t() \| nil` | No | Address neighborhood. |
| `city` | `String.t() \| nil` | No | Address city. |
| `uf` | `String.t() \| nil` | No | State abbreviation, such as SP. |
| `external_reference` | `String.t() \| nil` | No | Customer identifier in your system. For an existing customer, omit it to keep the reference, or send null or empty text to remove it. Use external_reference in the customer list to search for this value. |
| `metadata` | `map() \| nil` | No | Integration data associated with the resource. Supply key and text pairs. Keys are case-sensitive. Omission or {} preserves the data; null removes all pairs, and null for a key removes only that key. Empty text is a valid value. |

### ListCustomersParams

List customers.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `integer()` | No | Customers per page. Positive integers above the maximum use the maximum. Omitted, empty, zero, negative, or invalid values use 10. |
| `after` | `String.t()` | No | Copy page.next_after from the previous response to move forward. Use the cursor unchanged, keep the same filters, and do not send before as well. |
| `before` | `String.t()` | No | Copy page.previous_before from the previous response to go back one page. Keep the same filters and do not send after as well. |
| `identifier` | `String.t()` | No | Customer's public identifier, with the cus_ prefix. |
| `name` | `String.t()` | No | Search by customer name, with the newest records first. Leave it empty to ignore this filter. |
| `email` | `String.t()` | No | Filter by the customer's complete email address. |
| `document` | `String.t()` | No | Filter by the customer's complete CPF or CNPJ, with or without periods, slash, hyphen, and spaces. |
| `external_reference` | `String.t()` | No | Filter by the customer's current reference in your system, matching the complete value, including case and accents. It can be combined with other filters. After creating or editing the customer, search may take a few seconds to reflect the reference. Preserve the value when navigating by cursor. |

### DeleteCustomersBatchParams

Delete customers in a batch.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `identifiers` | `[String.t() \| nil]` | Yes | IDs of customers to delete. Repeated IDs do not cause more than one deletion. Invalid IDs and IDs of customers the key cannot access appear in invalid. |

### UpdateCustomerParams

Update an existing customer.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `full_name` | `String.t() \| nil` | No | Payer's full name. Omit it to keep the current value; send null or empty text to remove it. |
| `email` | `String.t() \| nil` | No | Payer's email address. Updating the email address does not send a message. Omit it to keep the current value; send null or empty text to remove it. |
| `dial_code` | `String.t() \| nil` | No | International dialing code. It may be supplied without phone_local. Omit it to keep the current value; send null or empty text to remove it. |
| `phone_local` | `String.t() \| nil` | No | Phone number without the dialing code, with or without punctuation. It may be supplied without dial_code. Omit it to keep the current value; send null or empty text to remove it. |
| `zip_code` | `String.t() \| nil` | No | Address CEP, with or without a hyphen. Updating the CEP does not fill other address fields. Omit it to keep the current value; send null or empty text to remove it. |
| `street` | `String.t() \| nil` | No | Address street. Omit it to keep the current value; send null or empty text to remove it. |
| `street_number` | `String.t() \| nil` | No | Address street number. Omit it to keep the current value; send null or empty text to remove it. |
| `complement` | `String.t() \| nil` | No | Address complement. Omit it to keep the current value; send null or empty text to remove it. |
| `neigh` | `String.t() \| nil` | No | Address neighborhood. Omit it to keep the current value; send null or empty text to remove it. |
| `city` | `String.t() \| nil` | No | Address city. Omit it to keep the current value; send null or empty text to remove it. |
| `uf` | `String.t() \| nil` | No | State abbreviation, such as SP. Omit it to keep the current value; send null or empty text to remove it. |
| `external_reference` | `String.t() \| nil` | No | Customer identifier in your system. Omit it to keep the current reference; send null or empty text to remove it. Use external_reference in the customer list to search for this value. |
| `metadata` | `map() \| nil` | No | Integration data associated with the resource. Supply key and text pairs. Keys are case-sensitive. Omission or {} preserves the data; null removes all pairs, and null for a key removes only that key. Empty text is a valid value. |

### UpdateAutomaticWithdrawalSettingsParams

Update automatic withdrawals.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `enabled` | `boolean()` | No | Enable or disable new withdrawal attempts. Disabling does not cancel withdrawals already requested. |
| `minimum_amount_cents` | `integer()` | No | Minimum balance for attempting a withdrawal, in Brazilian real cents. The amount withdrawn depends on the available balance and remaining Pix limit. |
| `time` | `String.t()` | No | Daily time in HH:mm format, using the São Paulo time zone. |

### GetBalanceForecastParams

Retrieve expected receipts.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `period` | `String.t()` | No | Period of expected receipt dates, using the São Paulo calendar. Includes today and prior days according to the option. Does not query due dates or project upcoming days. |

### CreateRefundParams

Request a refund.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `amount_cents` | `integer()` | Yes | Amount requested for refund, in Brazilian real cents. To refund everything, supply the remaining amount shown by the eligibility query. |
| `description` | `String.t() \| nil` | No | Refund request description. You may leave this field empty. |

### ListChargeRefundsParams

List refunds for a charge.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `integer()` | No | Refunds per page. Values above the maximum use the maximum; omitted, empty, text, zero, or negative values use the default. |
| `after` | `String.t()` | No | Cursor received in page.next_after to move forward. Copy the complete value and keep the same charge. Do not send it together with before. |
| `before` | `String.t()` | No | Cursor received in page.previous_before to move backward. Copy the complete value and keep the same charge. Do not send it together with after. |
| `created_gte` | `integer()` | No | Filter refunds requested at or after this instant, inclusive, in Unix seconds UTC. Uses the request creation date, regardless of completion. Preserve the value when changing pages. |
| `created_lte` | `integer()` | No | Filter refunds requested at or before this instant, inclusive, in Unix seconds UTC. If created_gte is supplied, this value must be greater than or equal to it. |

### GetChargeStatisticsParams

Retrieve charge statistics.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `period` | `String.t()` | No | Query period using the São Paulo calendar. today covers today; last_7_days, last_15_days, and last_30_days include today and prior days. Only those periods are accepted. start_at and end_at are response fields, not custom date filters. |

### CreateCheckoutLogoUploadParams

Prepare a logo upload.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `content_type` | `String.t()` | Yes | File content type: image/png or image/jpeg. |
| `file_size` | `integer()` | Yes | File size in bytes. |
| `width` | `integer()` | Yes | Image width in pixels. |
| `height` | `integer()` | Yes | Image height in pixels. |

### CreateCheckoutFaviconUploadParams

Prepare an icon upload.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `content_type` | `String.t()` | Yes | File content type: image/png or image/jpeg. |
| `file_size` | `integer()` | Yes | File size in bytes. |
| `width` | `integer()` | Yes | Icon width in pixels. Must equal its height. |
| `height` | `integer()` | Yes | Icon height in pixels. Must equal its width. |

### UpdateCheckoutSettingsParams

Update checkout customization.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `support_email` | `String.t() \| nil` | No | Support email displayed in checkout. Omission preserves the value; null or empty text removes the contact. |
| `hex_primary_color` | `String.t()` | No | Primary checkout color in #RRGGBB format. Omission preserves the value; null or empty text is not accepted. |
| `hex_secondary_color` | `String.t()` | No | Checkout background color in #RRGGBB format. Omission preserves the value; null or empty text is not accepted. |
| `logo_upload_id` | `String.t() \| nil` | No | ID returned when preparing the logo upload. Upload the file before associating it. Omission preserves the current image; null removes it. |
| `favicon_upload_id` | `String.t() \| nil` | No | ID returned when preparing the icon upload. Upload the file before associating it. Omission preserves the current image; null removes it. |

### ListDisputesParams

List disputes.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `integer()` | No | Disputes per page. Invalid values use the default; values above the maximum use the limit. |
| `after` | `String.t()` | No | Cursor from page.next_after in the previous response. Preserve filters and sort order; do not send it together with before. |
| `before` | `String.t()` | No | Cursor from page.previous_before to move backward. Preserve filters and sort order; do not send it together with after. |
| `stage` | `String.t()` | No | Comma-separated case stages: open, in_analysis, refund_in_analysis, closed, cancelled, rejected, or failed. Closed means the review has ended without confirming a favorable decision or refund. |
| `charge_id` | `String.t()` | No | Filter by the linked charge, using its complete public identifier. A valid ID without accessible cases returns an empty list. |
| `disputed_amount_cents` | `integer()` | No | Filter by the exact disputed amount, in Brazilian real cents. It does not represent the amount currently held. |
| `created_gte` | `integer()` | No | Include disputes created at or after this instant, in Unix seconds UTC. The boundary is inclusive. |
| `created_lte` | `integer()` | No | Include disputes created at or before this instant, in Unix seconds UTC. The boundary is inclusive and must be equal to or later than created_gte. |
| `sort_key` | `String.t()` | No | Field used to sort the list: creation date or disputed amount. |
| `sort_order` | `String.t()` | No | Ascending or descending order for the selected field. |

### CreatePaymentLinkParams

Create or retrieve a payment link.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `charge_id` | `String.t()` | Yes | Identifier of the existing charge. The link uses that charge's customer, amount, and due date. |
| `success_redirect_url` | `String.t() \| nil` | No | HTTPS return URL after confirmed payment. Omission, null, or empty text preserves the existing URL. |
| `cancel_redirect_url` | `String.t() \| nil` | No | HTTPS URL for returning to your website. Returning does not cancel the charge. Omission, null, or empty text preserves the existing URL. |
| `payment_method_types` | `[1 \| 2] \| nil` | No | Allowed methods for the link. Omission preserves the configuration; null removes the custom configuration. A list restricts checkout methods and cannot expand the methods allowed by the charge. |

### ListPaymentLinksParams

List payment links.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `integer()` | No | Links per page. |
| `after` | `String.t()` | No | Cursor received in page.next_after. Keep the same charge_id filter. |
| `before` | `String.t()` | No | Cursor received in page.previous_before. Do not send it together with after. |
| `charge_id` | `String.t()` | No | Identifier of the charge whose link you want to retrieve. |

### UpdatePaymentLinkParams

Update a payment link.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `is_active` | `boolean()` | No | Send false to pause checkout and true to reactivate the same URL. Omission preserves the current state. Pausing does not cancel an issued Pix or boleto or extend the due date. |
| `success_redirect_url` | `String.t() \| nil` | No | HTTPS return URL after confirmed payment. Omission, null, or empty text preserves the existing URL. To remove it, set clear_success_redirect_url to true without supplying a nonempty URL. |
| `cancel_redirect_url` | `String.t() \| nil` | No | HTTPS URL for returning to your website. Returning does not cancel the charge. Omission, null, or empty text preserves the existing URL. To remove it, set clear_cancel_redirect_url to true without supplying a nonempty URL. |
| `clear_success_redirect_url` | `boolean()` | No | Send true to remove the return destination after payment. False or omission does not request removal. Do not send true with a nonempty success_redirect_url. |
| `clear_cancel_redirect_url` | `boolean()` | No | Send true to remove the return destination for your website. False or omission does not request removal. Do not send true with a nonempty cancel_redirect_url. |
| `payment_method_types` | `[1 \| 2] \| nil` | No | Allowed methods for the link. Omission preserves the configuration; null removes the custom configuration. A list restricts checkout methods and cannot expand the methods allowed by the charge. |

### ListRefundsParams

List refunds.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `integer()` | No | Refunds per page. Values above the maximum use the maximum; omitted, empty, text, zero, or negative values use the default. |
| `after` | `String.t()` | No | Cursor received in page.next_after to move forward in this list. Copy the complete value. Do not use a charge-specific list cursor or send it together with before. |
| `before` | `String.t()` | No | Cursor received in page.previous_before to move backward in this list. Copy the complete value. Do not use a charge-specific list cursor or send it together with after. |
| `created_gte` | `integer()` | No | Filter refunds requested at or after this instant, inclusive, in Unix seconds UTC. Uses the request creation date, regardless of completion. Preserve the value when changing pages. |
| `created_lte` | `integer()` | No | Filter refunds requested at or before this instant, inclusive, in Unix seconds UTC. If created_gte is supplied, this value must be greater than or equal to it. |

### ConfigureSimulationScenarioParams

Prepare a scenario.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `action` | `String.t()` | Yes | Action to test: pix_issuance for Pix issuance, boleto_issuance for boleto issuance, or cancellation for cancellation. For cancellation, keep the charge open with Pix or boleto already issued, without confirming payment. |
| `outcome` | `String.t()` | Yes | Action result: pending leaves confirmation open; failed presents a failure. |

### ResolveSimulationScenarioParams

Resolve a pending scenario.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `action` | `String.t()` | Yes | Action to test: pix_issuance for Pix issuance, boleto_issuance for boleto issuance, or cancellation for cancellation. |
| `outcome` | `String.t()` | Yes | Result for the pending action: completed finishes the action; failed confirms failure. |

### IssueSimulationPaymentParams

Issue a test payment.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `payment_method` | `integer()` | Yes | Method to issue: 1 for Pix or 2 for boleto. It must be enabled on the charge. |

### CreateSimulationRefundParams

Simulate a pending refund.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `amount_cents` | `integer()` | Yes | Amount requested for refund, in Brazilian real cents. To refund everything, supply the remaining amount shown by the eligibility query. |
| `description` | `String.t() \| nil` | No | Refund request description. You may leave this field empty. |

### ListStatementsParams

Retrieve statements.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `integer()` | No | Entries per page. |
| `after` | `String.t()` | No | Cursor received in page.next_after to move forward. Keep the same filters and sort order. Use only after or before. |
| `before` | `String.t()` | No | Cursor received in page.previous_before to move backward. Keep the same filters and sort order. Use only after or before. |
| `statement_type` | `String.t()` | No | Comma-separated entry types: 1 receipt of funds; 2 fee; 3 service fee; 4 withdrawal; 5 refund; 6 partial refund; 7 adjustment credit; 8 adjustment debit; 9 hold; 10 release. |
| `reference_id` | `String.t()` | No | Identifier of the charge, dispute, withdrawal, or adjustment associated with the entry. Use the complete ID returned by Raims. |
| `created_gte` | `integer()` | No | Inclusive start of the period, in Unix seconds UTC. The filter uses the entry timestamp. |
| `created_lte` | `integer()` | No | Inclusive end of the period, in Unix seconds UTC. The supplied instant is the exact boundary; fractions later than the supplied second are outside the period. |
| `sort_order` | `String.t()` | No | Entry order by date: desc shows the newest first; asc shows the oldest first. |

### SetWebhookPauseParams

Pause or resume deliveries.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `is_paused` | `boolean()` | Yes | Send true to pause deliveries or false to resume them. Repeating the same value preserves the state and pause timestamp. |

### ListWebhooksParams

List webhooks.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `integer()` | No | Records per page. The response reports the effective size in page.page_size. |
| `after` | `String.t()` | No | To move forward, copy page.next_after from the previous response. Use only after or before. |
| `before` | `String.t()` | No | To move backward, copy page.previous_before from the previous response. Use only after or before. |

### CreateWebhookParams

Create a webhook.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `name` | `String.t()` | Yes | Name identifying the destination. |
| `url` | `String.t()` | Yes | HTTPS URL receiving events. Use the default port 443 and a public address outside Raims. |
| `events` | `[String.t()]` | Yes | Event codes this destination should receive. Consult the available event catalog. |
| `is_active` | `boolean()` | No | Set whether the destination can receive events after registration. |

### UpdateWebhookParams

Update a webhook.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `name` | `String.t()` | No | New webhook name. |
| `url` | `String.t()` | No | New HTTPS URL receiving events, on the default port 443. |
| `events` | `[String.t()]` | No | Complete list of events the destination should receive. Replaces the previous selection. |
| `is_active` | `boolean()` | No | Use true to allow deliveries or false to disable the destination. |

### RotateWebhookSecretParams

Rotate the signing secret.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `grace_period_seconds` | `integer()` | No | Period during which the previous secret can continue signing deliveries. Zero generates a new signature and ends the validity of previous secrets, including during an active transition. Requests already authorized or in progress may arrive with the previous signature. |

### ListWithdrawalDestinationsParams

List withdrawal destinations.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `integer()` | No | Records considered for the page. The list may contain fewer destinations and still indicate a next page; continue while page.has_next is true. |
| `after` | `String.t()` | No | Cursor received in page.next_after to move forward. Copy the entire value and keep the same API key. Do not send it together with before. |
| `before` | `String.t()` | No | Cursor received in page.previous_before to move backward. Copy the entire value and keep the same API key. Do not send it together with after. |

### CreateWithdrawalParams

Request a withdrawal.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `amount_cents` | `integer()` | Yes | Total amount to withdraw, in Brazilian real cents, including the fee. Consult withdrawal conditions to check the balance, fee, and limits before requesting. |
| `expected_destination_id` | `String.t() \| nil` | No | ID of the account's own destination that must remain selected as the default. Copy the id returned when retrieving destinations. If the destination changes or becomes invalid, the withdrawal is rejected. Omission or null uses the current default destination. |

### ListWithdrawalsParams

List withdrawals.

| Field | Elixir value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `integer()` | No | Withdrawals per page. |
| `after` | `String.t()` | No | next_after cursor returned on the previous page. Keep the same filters and query sort order. |
| `before` | `String.t()` | No | previous_before cursor returned on the next page. Keep the same filters and query sort order. |
| `status` | `String.t()` | No | Filter by one or more comma-separated states: PENDING, PROCESSING, COMPLETED, FAILED, or CANCELED. |
| `requested_gte` | `integer()` | No | Return withdrawals requested at or after this instant, inclusive. Supply Unix seconds UTC. |
| `requested_lte` | `integer()` | No | Return withdrawals requested at or before this instant, inclusive. Supply Unix seconds UTC. |
| `sort_order` | `String.t()` | No | Sort by request date: desc shows the newest first; asc shows the oldest first. |

## Named public values

Functions in `Raims.EnumValues` return values from the public contract. Numeric
values receive names only when the contract publishes explicit labels.

| Function | Value |
| --- | --- |
| `Raims.EnumValues.account_context_amount_unit_cents()` | `"cents"` |
| `Raims.EnumValues.account_context_business_timezone_america_sao_paulo()` | `"America/Sao_Paulo"` |
| `Raims.EnumValues.account_context_company_status_active()` | `"active"` |
| `Raims.EnumValues.account_context_company_status_limited()` | `"limited"` |
| `Raims.EnumValues.account_context_company_status_pending()` | `"pending"` |
| `Raims.EnumValues.account_context_currency_brl()` | `"BRL"` |
| `Raims.EnumValues.account_context_data_environment_production()` | `"production"` |
| `Raims.EnumValues.account_context_data_environment_sandbox()` | `"sandbox"` |
| `Raims.EnumValues.account_context_timestamp_unit_unix_seconds()` | `"unix_seconds"` |
| `Raims.EnumValues.balance_forecast_period_last_15_days()` | `"last_15_days"` |
| `Raims.EnumValues.balance_forecast_period_last_30_days()` | `"last_30_days"` |
| `Raims.EnumValues.balance_forecast_period_last_7_days()` | `"last_7_days"` |
| `Raims.EnumValues.balance_forecast_period_today()` | `"today"` |
| `Raims.EnumValues.charge_created_payment_method_types_item_boleto()` | `2` |
| `Raims.EnumValues.charge_created_payment_method_types_item_pix()` | `1` |
| `Raims.EnumValues.charge_list_item_payment_method_types_item_boleto()` | `2` |
| `Raims.EnumValues.charge_list_item_payment_method_types_item_pix()` | `1` |
| `Raims.EnumValues.charge_payment_information_boleto_payment_status_awaiting_payment()` | `"awaiting_payment"` |
| `Raims.EnumValues.charge_payment_information_boleto_payment_status_compensated()` | `"compensated"` |
| `Raims.EnumValues.charge_payment_information_boleto_payment_status_settled()` | `"settled"` |
| `Raims.EnumValues.charge_payment_information_boleto_status_available()` | `"available"` |
| `Raims.EnumValues.charge_payment_information_boleto_status_failed()` | `"failed"` |
| `Raims.EnumValues.charge_payment_information_boleto_status_not_generated()` | `"not_generated"` |
| `Raims.EnumValues.charge_payment_information_boleto_status_pending()` | `"pending"` |
| `Raims.EnumValues.charge_payment_information_pix_status_available()` | `"available"` |
| `Raims.EnumValues.charge_payment_information_pix_status_failed()` | `"failed"` |
| `Raims.EnumValues.charge_payment_information_pix_status_not_generated()` | `"not_generated"` |
| `Raims.EnumValues.charge_payment_information_pix_status_pending()` | `"pending"` |
| `Raims.EnumValues.charge_payment_method_types_item_boleto()` | `2` |
| `Raims.EnumValues.charge_payment_method_types_item_pix()` | `1` |
| `Raims.EnumValues.charge_scenario_action_boleto_issuance()` | `"boleto_issuance"` |
| `Raims.EnumValues.charge_scenario_action_cancellation()` | `"cancellation"` |
| `Raims.EnumValues.charge_scenario_action_pix_issuance()` | `"pix_issuance"` |
| `Raims.EnumValues.charge_scenario_outcome_completed()` | `"completed"` |
| `Raims.EnumValues.charge_scenario_outcome_failed()` | `"failed"` |
| `Raims.EnumValues.charge_scenario_outcome_pending()` | `"pending"` |
| `Raims.EnumValues.charge_scenario_request_action_boleto_issuance()` | `"boleto_issuance"` |
| `Raims.EnumValues.charge_scenario_request_action_cancellation()` | `"cancellation"` |
| `Raims.EnumValues.charge_scenario_request_action_pix_issuance()` | `"pix_issuance"` |
| `Raims.EnumValues.charge_scenario_request_outcome_failed()` | `"failed"` |
| `Raims.EnumValues.charge_scenario_request_outcome_pending()` | `"pending"` |
| `Raims.EnumValues.charge_scenario_state_completed()` | `"completed"` |
| `Raims.EnumValues.charge_scenario_state_configured()` | `"configured"` |
| `Raims.EnumValues.charge_scenario_state_failed()` | `"failed"` |
| `Raims.EnumValues.charge_scenario_state_pending()` | `"pending"` |
| `Raims.EnumValues.charge_statistics_period_last_15_days()` | `"last_15_days"` |
| `Raims.EnumValues.charge_statistics_period_last_30_days()` | `"last_30_days"` |
| `Raims.EnumValues.charge_statistics_period_last_7_days()` | `"last_7_days"` |
| `Raims.EnumValues.charge_statistics_period_today()` | `"today"` |
| `Raims.EnumValues.checkout_asset_error_code_checkout_asset_invalid_image()` | `"CHECKOUT_ASSET_INVALID_IMAGE"` |
| `Raims.EnumValues.checkout_asset_error_code_checkout_asset_processing_failed()` | `"CHECKOUT_ASSET_PROCESSING_FAILED"` |
| `Raims.EnumValues.checkout_asset_error_code_checkout_asset_upload_not_found()` | `"CHECKOUT_ASSET_UPLOAD_NOT_FOUND"` |
| `Raims.EnumValues.checkout_asset_status_absent()` | `"absent"` |
| `Raims.EnumValues.checkout_asset_status_failed()` | `"failed"` |
| `Raims.EnumValues.checkout_asset_status_pending()` | `"pending"` |
| `Raims.EnumValues.checkout_asset_status_ready()` | `"ready"` |
| `Raims.EnumValues.checkout_asset_upload_content_type_image_jpeg()` | `"image/jpeg"` |
| `Raims.EnumValues.checkout_asset_upload_content_type_image_png()` | `"image/png"` |
| `Raims.EnumValues.create_charge_request_payment_method_boleto()` | `2` |
| `Raims.EnumValues.create_charge_request_payment_method_indefinido()` | `0` |
| `Raims.EnumValues.create_charge_request_payment_method_pix()` | `1` |
| `Raims.EnumValues.create_charge_request_payment_method_types_item_boleto()` | `2` |
| `Raims.EnumValues.create_charge_request_payment_method_types_item_pix()` | `1` |
| `Raims.EnumValues.create_checkout_favicon_upload_request_content_type_image_jpeg()` | `"image/jpeg"` |
| `Raims.EnumValues.create_checkout_favicon_upload_request_content_type_image_png()` | `"image/png"` |
| `Raims.EnumValues.create_checkout_logo_upload_request_content_type_image_jpeg()` | `"image/jpeg"` |
| `Raims.EnumValues.create_checkout_logo_upload_request_content_type_image_png()` | `"image/png"` |
| `Raims.EnumValues.create_payment_link_request_payment_method_types_item_boleto()` | `2` |
| `Raims.EnumValues.create_payment_link_request_payment_method_types_item_pix()` | `1` |
| `Raims.EnumValues.create_webhook_request_events_item_charge_canceled()` | `"charge.canceled"` |
| `Raims.EnumValues.create_webhook_request_events_item_charge_created()` | `"charge.created"` |
| `Raims.EnumValues.create_webhook_request_events_item_charge_failed()` | `"charge.failed"` |
| `Raims.EnumValues.create_webhook_request_events_item_charge_paid()` | `"charge.paid"` |
| `Raims.EnumValues.create_webhook_request_events_item_refund_completed()` | `"refund.completed"` |
| `Raims.EnumValues.create_webhook_request_events_item_refund_failed()` | `"refund.failed"` |
| `Raims.EnumValues.create_webhook_request_events_item_refund_requested()` | `"refund.requested"` |
| `Raims.EnumValues.customer_created_tax_id_type_cnpj()` | `"cnpj"` |
| `Raims.EnumValues.customer_created_tax_id_type_cpf()` | `"cpf"` |
| `Raims.EnumValues.customer_list_item_tax_id_type_cnpj()` | `"cnpj"` |
| `Raims.EnumValues.customer_list_item_tax_id_type_cpf()` | `"cpf"` |
| `Raims.EnumValues.dispute_infraction_result_agreed()` | `"agreed"` |
| `Raims.EnumValues.dispute_infraction_result_disagreed()` | `"disagreed"` |
| `Raims.EnumValues.dispute_kind_chargeback()` | `"chargeback"` |
| `Raims.EnumValues.dispute_kind_med()` | `"med"` |
| `Raims.EnumValues.dispute_list_item_kind_chargeback()` | `"chargeback"` |
| `Raims.EnumValues.dispute_list_item_kind_med()` | `"med"` |
| `Raims.EnumValues.dispute_list_item_stage_cancelled()` | `"cancelled"` |
| `Raims.EnumValues.dispute_list_item_stage_closed()` | `"closed"` |
| `Raims.EnumValues.dispute_list_item_stage_failed()` | `"failed"` |
| `Raims.EnumValues.dispute_list_item_stage_in_analysis()` | `"in_analysis"` |
| `Raims.EnumValues.dispute_list_item_stage_open()` | `"open"` |
| `Raims.EnumValues.dispute_list_item_stage_refund_in_analysis()` | `"refund_in_analysis"` |
| `Raims.EnumValues.dispute_list_item_stage_rejected()` | `"rejected"` |
| `Raims.EnumValues.dispute_refund_result_partially_accepted()` | `"partially_accepted"` |
| `Raims.EnumValues.dispute_refund_result_rejected()` | `"rejected"` |
| `Raims.EnumValues.dispute_refund_result_totally_accepted()` | `"totally_accepted"` |
| `Raims.EnumValues.dispute_stage_cancelled()` | `"cancelled"` |
| `Raims.EnumValues.dispute_stage_closed()` | `"closed"` |
| `Raims.EnumValues.dispute_stage_failed()` | `"failed"` |
| `Raims.EnumValues.dispute_stage_in_analysis()` | `"in_analysis"` |
| `Raims.EnumValues.dispute_stage_open()` | `"open"` |
| `Raims.EnumValues.dispute_stage_refund_in_analysis()` | `"refund_in_analysis"` |
| `Raims.EnumValues.dispute_stage_rejected()` | `"rejected"` |
| `Raims.EnumValues.payment_link_details_effective_payment_method_types_item_boleto()` | `2` |
| `Raims.EnumValues.payment_link_details_effective_payment_method_types_item_pix()` | `1` |
| `Raims.EnumValues.payment_link_details_payment_method_types_item_boleto()` | `2` |
| `Raims.EnumValues.payment_link_details_payment_method_types_item_pix()` | `1` |
| `Raims.EnumValues.payment_link_payment_method_types_item_boleto()` | `2` |
| `Raims.EnumValues.payment_link_payment_method_types_item_pix()` | `1` |
| `Raims.EnumValues.payment_link_unavailable_reason_code_boleto_awaiting_settlement()` | `"BOLETO_AWAITING_SETTLEMENT"` |
| `Raims.EnumValues.payment_link_unavailable_reason_code_charge_expired()` | `"CHARGE_EXPIRED"` |
| `Raims.EnumValues.payment_link_unavailable_reason_code_charge_not_open()` | `"CHARGE_NOT_OPEN"` |
| `Raims.EnumValues.payment_link_unavailable_reason_code_payment_link_paused()` | `"PAYMENT_LINK_PAUSED"` |
| `Raims.EnumValues.payment_link_unavailable_reason_code_payment_methods_unavailable()` | `"PAYMENT_METHODS_UNAVAILABLE"` |
| `Raims.EnumValues.payment_link_unavailable_reason_code_pix_cancellation_pending()` | `"PIX_CANCELLATION_PENDING"` |
| `Raims.EnumValues.payment_link_unavailable_reason_code_pix_cancelled()` | `"PIX_CANCELLED"` |
| `Raims.EnumValues.refund_failure_reason_code_refund_failure_reason_unavailable()` | `"REFUND_FAILURE_REASON_UNAVAILABLE"` |
| `Raims.EnumValues.refund_failure_reason_code_refund_not_submitted()` | `"REFUND_NOT_SUBMITTED"` |
| `Raims.EnumValues.refund_failure_reason_code_refund_processing_failed()` | `"REFUND_PROCESSING_FAILED"` |
| `Raims.EnumValues.refund_failure_reason_code_refund_processing_unavailable()` | `"REFUND_PROCESSING_UNAVAILABLE"` |
| `Raims.EnumValues.refund_failure_reason_code_refund_rejected()` | `"REFUND_REJECTED"` |
| `Raims.EnumValues.refund_status_accepted()` | `"accepted"` |
| `Raims.EnumValues.refund_status_completed()` | `"completed"` |
| `Raims.EnumValues.refund_status_failed()` | `"failed"` |
| `Raims.EnumValues.refund_status_reserved()` | `"reserved"` |
| `Raims.EnumValues.refund_status_unknown()` | `"unknown"` |
| `Raims.EnumValues.refund_unavailable_reason_code_pix_refund_already_completed()` | `"PIX_REFUND_ALREADY_COMPLETED"` |
| `Raims.EnumValues.refund_unavailable_reason_code_pix_refund_cashin_not_found()` | `"PIX_REFUND_CASHIN_NOT_FOUND"` |
| `Raims.EnumValues.refund_unavailable_reason_code_pix_refund_insufficient_balance()` | `"PIX_REFUND_INSUFFICIENT_BALANCE"` |
| `Raims.EnumValues.refund_unavailable_reason_code_pix_refund_in_progress()` | `"PIX_REFUND_IN_PROGRESS"` |
| `Raims.EnumValues.refund_unavailable_reason_code_pix_refund_not_available()` | `"PIX_REFUND_NOT_AVAILABLE"` |
| `Raims.EnumValues.refund_unavailable_reason_code_pix_refund_provider_account_not_ready()` | `"PIX_REFUND_PROVIDER_ACCOUNT_NOT_READY"` |
| `Raims.EnumValues.refund_unavailable_reason_code_pix_refund_provider_unavailable()` | `"PIX_REFUND_PROVIDER_UNAVAILABLE"` |
| `Raims.EnumValues.resolve_charge_scenario_request_action_boleto_issuance()` | `"boleto_issuance"` |
| `Raims.EnumValues.resolve_charge_scenario_request_action_cancellation()` | `"cancellation"` |
| `Raims.EnumValues.resolve_charge_scenario_request_action_pix_issuance()` | `"pix_issuance"` |
| `Raims.EnumValues.resolve_charge_scenario_request_outcome_completed()` | `"completed"` |
| `Raims.EnumValues.resolve_charge_scenario_request_outcome_failed()` | `"failed"` |
| `Raims.EnumValues.statement_reference_type_ajuste()` | `4` |
| `Raims.EnumValues.statement_reference_type_cobran_a()` | `1` |
| `Raims.EnumValues.statement_reference_type_contesta_o()` | `2` |
| `Raims.EnumValues.statement_reference_type_manual()` | `5` |
| `Raims.EnumValues.statement_reference_type_saque()` | `3` |
| `Raims.EnumValues.statement_reference_type_sem_refer_ncia()` | `nil` |
| `Raims.EnumValues.statement_statement_type_bloqueio()` | `9` |
| `Raims.EnumValues.statement_statement_type_cr_dito_por_ajuste()` | `7` |
| `Raims.EnumValues.statement_statement_type_devolu_o()` | `5` |
| `Raims.EnumValues.statement_statement_type_devolu_o_parcial()` | `6` |
| `Raims.EnumValues.statement_statement_type_d_bito_por_ajuste()` | `8` |
| `Raims.EnumValues.statement_statement_type_libera_o()` | `10` |
| `Raims.EnumValues.statement_statement_type_recebimento()` | `1` |
| `Raims.EnumValues.statement_statement_type_saque()` | `4` |
| `Raims.EnumValues.statement_statement_type_tarifa()` | `2` |
| `Raims.EnumValues.statement_statement_type_tarifa_de_servi_o()` | `3` |
| `Raims.EnumValues.update_payment_link_request_payment_method_types_item_boleto()` | `2` |
| `Raims.EnumValues.update_payment_link_request_payment_method_types_item_pix()` | `1` |
| `Raims.EnumValues.webhook_created_disabled_reason_continuous_failure()` | `"continuous_failure"` |
| `Raims.EnumValues.webhook_created_disabled_reason_manual()` | `"manual"` |
| `Raims.EnumValues.webhook_disabled_reason_continuous_failure()` | `"continuous_failure"` |
| `Raims.EnumValues.webhook_disabled_reason_manual()` | `"manual"` |
| `Raims.EnumValues.webhook_event_type_code_charge_canceled()` | `"charge.canceled"` |
| `Raims.EnumValues.webhook_event_type_code_charge_created()` | `"charge.created"` |
| `Raims.EnumValues.webhook_event_type_code_charge_failed()` | `"charge.failed"` |
| `Raims.EnumValues.webhook_event_type_code_charge_paid()` | `"charge.paid"` |
| `Raims.EnumValues.webhook_event_type_code_refund_completed()` | `"refund.completed"` |
| `Raims.EnumValues.webhook_event_type_code_refund_failed()` | `"refund.failed"` |
| `Raims.EnumValues.webhook_event_type_code_refund_requested()` | `"refund.requested"` |
| `Raims.EnumValues.webhook_health_status_disabled()` | `"disabled"` |
| `Raims.EnumValues.webhook_health_status_failing()` | `"failing"` |
| `Raims.EnumValues.webhook_health_status_healthy()` | `"healthy"` |
| `Raims.EnumValues.webhook_health_status_unknown()` | `"unknown"` |
| `Raims.EnumValues.withdrawal_destination_key_type_cnpj()` | `"CNPJ"` |
| `Raims.EnumValues.withdrawal_destination_key_type_email()` | `"EMAIL"` |
| `Raims.EnumValues.withdrawal_destination_key_type_evp()` | `"EVP"` |
| `Raims.EnumValues.withdrawal_destination_key_type_phone()` | `"PHONE"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_above_maximum_withdrawal()` | `"ABOVE_MAXIMUM_WITHDRAWAL"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_bank_account_unavailable()` | `"BANK_ACCOUNT_UNAVAILABLE"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_bank_processing_failure()` | `"BANK_PROCESSING_FAILURE"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_bank_timeout()` | `"BANK_TIMEOUT"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_bank_unsupported()` | `"BANK_UNSUPPORTED"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_below_minimum_withdrawal()` | `"BELOW_MINIMUM_WITHDRAWAL"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_blocked_balance()` | `"BLOCKED_BALANCE"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_duplicated_request()` | `"DUPLICATED_REQUEST"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_insufficient_balance()` | `"INSUFFICIENT_BALANCE"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_internal_error()` | `"INTERNAL_ERROR"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_invalid_account_type()` | `"INVALID_ACCOUNT_TYPE"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_invalid_bank_account()` | `"INVALID_BANK_ACCOUNT"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_risk_policy_rejected()` | `"RISK_POLICY_REJECTED"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_withdrawal_failure_reason_unavailable()` | `"WITHDRAWAL_FAILURE_REASON_UNAVAILABLE"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_withdrawal_limit_reached()` | `"WITHDRAWAL_LIMIT_REACHED"` |
| `Raims.EnumValues.withdrawal_failure_reason_code_withdrawal_temporarily_unavailable()` | `"WITHDRAWAL_TEMPORARILY_UNAVAILABLE"` |
| `Raims.EnumValues.withdrawal_pix_destination_key_type_cnpj()` | `"CNPJ"` |
| `Raims.EnumValues.withdrawal_pix_destination_key_type_email()` | `"EMAIL"` |
| `Raims.EnumValues.withdrawal_pix_destination_key_type_evp()` | `"EVP"` |
| `Raims.EnumValues.withdrawal_pix_destination_key_type_phone()` | `"PHONE"` |
| `Raims.EnumValues.withdrawal_status_canceled()` | `"CANCELED"` |
| `Raims.EnumValues.withdrawal_status_completed()` | `"COMPLETED"` |
| `Raims.EnumValues.withdrawal_status_failed()` | `"FAILED"` |
| `Raims.EnumValues.withdrawal_status_pending()` | `"PENDING"` |
| `Raims.EnumValues.withdrawal_status_processing()` | `"PROCESSING"` |
| `Raims.EnumValues.withdrawal_status_unknown()` | `"UNKNOWN"` |
