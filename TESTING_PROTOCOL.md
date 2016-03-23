1. Test turbolinks/jquery document ready events. There are different
 loading workflow by the page you start (i) map and (ii) other pages
 (e.g. /documents).
 1. Test:
  * open browser on /documents
  * navigate to /map
  * test:
   * autocomplete place field
   * date range filter
 2. Test
  * open browser on /map
  * test:
   * autocomplete place field
   * date range filter

2. Browser anchor to particular event (`AddressBlock`) when are you navigate 
 form map popup to documents. It is done by JS.
 1. Test
  * navigate to /map
  * clinck on any event (popup dialog showns)
  * click to any document
  * test:
   * you are "anchored" to right location in document
  (test it for events, which are (i) at the last bottom of document,
  (ii) at begging of the document)

3. LocalAdministrationUnits pages are different for (i) common user (ii)
   lau_admin and (iii) admin
 1. Test
  * make yourself common user (registered or not)
  * navigate to `/local_administration_units` and click to any "Kraj"
  * Check that you _cannot_ see:
   a. "Seznam oprávněných uživatelů"
   b. "Seznam e-mailových adres, ze kterých se příjmají dokumenty"
   c. neither edit this values
 1. Test
  * make yourself admin (`User.find_by(email: '....').update_column(:role, :admin`)
  * navigate to `/local_administration_units` and click to any "Kraj"
  * check that you see:
   a. "Seznam oprávněných uživatelů"
   b. "Seznam e-mailových adres, ze kterých se příjmají dokumenty"
  * Test that you can add and remove to there lists.
 2. Test
  * make yourself `las_admin` role `admin` by
    `(LocalAdministrationUnitAdmin.create(local_administration_unit_id: 32, user: 1, role: 'admin')` you can see the LAU number in browser url.
  * navigate to particular LAU
  * check that you can see:
   a. "Seznam oprávněných uživatelů"
   b. "Seznam e-mailových adres, ze kterých se příjmají dokumenty"
  * Test that you can add and remove to there lists.
 3. Test
  * make yourself `las_admin` role `operator` by
    `(LocalAdministrationUnitAdmin.create(local_administration_unit_id: 32, user: 1, role: 'operator')` you can see the LAU number in browser url.
  * navigate to particular LAU
  * check that you can see:
   a. "Seznam oprávněných uživatelů"
   b. "Seznam e-mailových adres, ze kterých se příjmají dokumenty"
  * Test that you _cannot_ add, edit and remove to there lists.
