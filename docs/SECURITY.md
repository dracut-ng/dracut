Security is very important to us. If you discover any issue regarding security, we'd appreciate a non-public disclosure of
the information, so  please disclose the information responsibly by sending an email to Harald Hoyer <harald@profian.com> and not by creating a GitHub issue. 
We will respond swiftly to fix verifiable security issues with the disclosure being coordinated with distributions and relevant security teams.

The selinux module has been obsoleted due to the fact that the policy should be loaded after switch root in order
to avoid boot failures with more recent kernels and/or particular policies. It should only be needed for particular backwards-compatibility cases.
