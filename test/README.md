# Dracut tests

The "Dracut Developer Guidelines" page in the main documentation has a
section that explains how to use these tests:
https://dracut-ng.github.io/dracut/developer/hacking.html#_testsuite

The sources of that documentation are located in the
[doc_site/](/doc_site) folder at the top-level of this repository.

To find what tests are run by GitHub CI and in which configurations,
this is not a bad starting point:

   git grep -C 5 test/ -- .github/workflows/

## Numbering

The tests are grouped by topic and use following numbering schema:

* 10-19: core modules
* 20-29: multiple boot drives
* 30-39: live boot
* 40-49: systemd
* 60-69: basic networking (NFS)
* 70-79: advanced networking (iSCSI, NBD)
* 80-89: Dracut binaries
