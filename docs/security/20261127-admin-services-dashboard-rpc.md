# Admin services dashboard RPC

The service admin page previously read `service_orders.select('*')` and then separately read `payment_allocations` joined to `payments`. This patch replaces both requests with `admin_get_services_dashboard()`.

- Explicit service projection only; no unrestricted `*`.
- Computes paid totals only from allocations whose payment status is `успешно`.
- Requires non-null `auth.uid()` and `private.has_admin_role()`.
- SECURITY DEFINER, fixed `search_path=pg_catalog`, schema-qualified table references.
- EXECUTE only for authenticated; PUBLIC and anon revoked.
- Depends on the protected role foundation. This helper does not yet exist in production, so this source cannot be released until staging role setup and test assignments are complete.

Staging tests: anonymous and ordinary authenticated must be denied; admin/owner may load the list; cancelled services remain filterable; paid totals match successful allocations; pending allocations do not count.
No production SQL or deployment was performed.
