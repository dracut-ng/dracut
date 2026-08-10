[Rendered view](https://github.com/dracut-ng/dracut/blob/main/NEWS.md)

dracut-112
=============

#### Notes

This release includes the following security related commits:
* **network-legacy:**  sanitize DHCP values in dhclient-script.sh ([11577739](https://github.com/dracut-ng/dracut/commit/11577739221ff38c1fd29abbba51a6c797376ed6))
* **overlayfs-crypt:**  prevent eval injection in parse_overlay_opts() ([584e95be](https://github.com/dracut-ng/dracut/commit/584e95bea90cedd12d9190e9b09bb45e1aa26b08))
* **dracut-lib:**  sanitize variable assignments using eval ([4d2d812b](https://github.com/dracut-ng/dracut/commit/4d2d812bed056ca2c671612d960911b075c99dd9))
* **base:**  add escape function implementing printf %q ([207c3397](https://github.com/dracut-ng/dracut/commit/207c339728eff81127469c2f6fe106447c781009))
* **systemd-networkd:** escape values from DHCP options ([b456aee2](https://github.com/dracut-ng/dracut/commit/b456aee2fc61c47db0d9a408634820969e7359df))
* **iscsi:**  normalize initiator and target names ([843af3e7](https://github.com/dracut-ng/dracut/commit/843af3e751782285cd2bc7c9a3a9d33e843fb91d))
* **net-lib:**  validate iSCSI LUN parameters ([05c02db9](https://github.com/dracut-ng/dracut/commit/05c02db994ca322371a40695a3cc223faa1c7258))

This release includes the following new dracut modules:
* **chrony:**  introducing the chrony module ([4d64d0b9](https://github.com/dracut-ng/dracut/commit/4d64d0b99dd7267764272dbc4a210ccbda2db3db))
* **qcom-adsp:**  add module to load Qualcomm ADSP module pre-udev ([647a685d](https://github.com/dracut-ng/dracut/commit/647a685d3567dcf42fde10e1ae258967441e3223))

#### Bug Fixes

*   remove basename calls ([1898470b](https://github.com/dracut-ng/dracut/commit/1898470b01f6ba8b2d3660ef438eae37e362c8de))
*   remove dirname calls ([66111f49](https://github.com/dracut-ng/dracut/commit/66111f4969f246995686b2ef67d851282629ed5d))
*   replace true by : ([37717095](https://github.com/dracut-ng/dracut/commit/37717095083ebdf46fce7c7c399b6713cd53f232))
* **base:**  use printf instead of echo for hook variable ([ceadcea0](https://github.com/dracut-ng/dracut/commit/ceadcea055fead6b8a218c5e854b68ff3e0ac603))
* **bluetooth:**  skip warning when module is explicitly requested ([f334ea7c](https://github.com/dracut-ng/dracut/commit/f334ea7cf7a95c042a47942039ad54fbcdf46c39))
* **crypt:**  do not call return to exit a systemd generator ([fbb7270e](https://github.com/dracut-ng/dracut/commit/fbb7270edcf9fbc1c60959dc35e532dfe5c382b8), closes [#2490](https://github.com/dracut-ng/dracut/issues/2490))
* **dbus:**  restrict After/Requires removal patterns ([95a4da1b](https://github.com/dracut-ng/dracut/commit/95a4da1b2273b29dd4d558790b2f301e46616040))
* **docs:**  declare the correct location to report vulnerabilities ([6a9d409f](https://github.com/dracut-ng/dracut/commit/6a9d409fe418439319377b90ab5717b12d52915f))
* **dracut:**
  *  write force_drivers cmdline file in one step ([f72f94a2](https://github.com/dracut-ng/dracut/commit/f72f94a25dcf125fc050250159ad5efe6831d088))
  *  use dstdir in build_ld_cache() ([6b7db010](https://github.com/dracut-ng/dracut/commit/6b7db010224221af4a09772b73a40e759ad30506))
  *  do not exit the loop in push_user_devs() without checking all items ([573b91ee](https://github.com/dracut-ng/dracut/commit/573b91ee99bb1890f89f073962cb96680379acee))
  *  do not exit the loop in push_host_devs() without checking all items ([b57d2c2e](https://github.com/dracut-ng/dracut/commit/b57d2c2e6f5550b2047be74bf6cfe82a5a3f880a))
  *  log warning if touch fails ([fcffd4a0](https://github.com/dracut-ng/dracut/commit/fcffd4a0e3ee840b903c4ab45d06eb1ca881cce3))
  *  two typos in the 3cpio fallback ([852aeeb2](https://github.com/dracut-ng/dracut/commit/852aeeb21f6771a4112f0d08061ac19518dd149b))
  *  default to hostonly_cmdline=no in chroot ([67d82872](https://github.com/dracut-ng/dracut/commit/67d82872bb0e2bec7d046cce04de939edd30f453))
  *  properly pass user-supplied SBAT to ukify ([abef6535](https://github.com/dracut-ng/dracut/commit/abef65354833834092df092c83d0cbcbe8b85508))
  *  remove support for tmpfilesconfdir ([fb09ec26](https://github.com/dracut-ng/dracut/commit/fb09ec26b124705028c371089e42608c4e1585de))
  *  support chmod applet from busybox ([8a0ee588](https://github.com/dracut-ng/dracut/commit/8a0ee588c148a5cfc8b5f58ae7716eedde840562))
* **dracut-functions:**
  *  reset _found flag per rule in inst_rules() ([a0383c8d](https://github.com/dracut-ng/dracut/commit/a0383c8d1260745fa16c7249ac04310e0473fb47))
  *  correct hostonly path for Gentoo sysusers ([f037de42](https://github.com/dracut-ng/dracut/commit/f037de42be8ca69ef0fe422ae50b699c131754a1))
* **dracut-install:**
  *  check return value in modalias read() ([379e6b35](https://github.com/dracut-ng/dracut/commit/379e6b359d8c47b86e0359d85d7c9ccbac5b8d88))
  *  handle empty string in dir_len() ([0224b30e](https://github.com/dracut-ng/dracut/commit/0224b30e43020639095d3c98df073e297ba233a3))
  *  remove FTS_NOSTAT in install_modules() fts traversal ([40e7af01](https://github.com/dracut-ng/dracut/commit/40e7af014b47ab91ef559610af3cb3f8dbf0fbb9))
* **dracut-lib:**  sanitize variable assignments using eval ([4d2d812b](https://github.com/dracut-ng/dracut/commit/4d2d812bed056ca2c671612d960911b075c99dd9))
* **dracut-systemd:**  add ordering constraints ([8aa5c93b](https://github.com/dracut-ng/dracut/commit/8aa5c93b29f1bbd214d257e169489b752ab71074))
* **dracut.conf.5:**  move fstab/chroot warning to hostonly_mode section ([1374dc95](https://github.com/dracut-ng/dracut/commit/1374dc954ebd7ffee223932bcef23060e7941109))
* **iscsi:**
  *  normalize initiator and target names ([843af3e7](https://github.com/dracut-ng/dracut/commit/843af3e751782285cd2bc7c9a3a9d33e843fb91d))
  *  handle empty URI in firmware boot mode ([3c1a3846](https://github.com/dracut-ng/dracut/commit/3c1a3846a0435cc553494d4e7a40258ce3329cb6))
* **kernel-modules:**
  *  include xhci-pci-prom21 for early USB ([bccf5798](https://github.com/dracut-ng/dracut/commit/bccf5798f8d6930a8edbbfce84feff4d0f325568))
  *  add Mediatek MTU3 USB controller ([8f243cfb](https://github.com/dracut-ng/dracut/commit/8f243cfb94fb2e4043d46031fd988db83d277f6b))
* **lunmask:**  use function in parse-lunmask.sh ([4815bf38](https://github.com/dracut-ng/dracut/commit/4815bf387b8ac455d1f8448176f8ab7463848d5a))
* **mdraid:**
  *  escape slash in sed regular expression ([a76d9cbe](https://github.com/dracut-ng/dracut/commit/a76d9cbe75bf378867b8800171d1ddb052b4f60a))
  *  install 59-persistent-storage-md.rules only when needed ([78c043a9](https://github.com/dracut-ng/dracut/commit/78c043a90a837d2494c573a7cf82d083f3fda9fe))
* **net-lib:**  validate iSCSI LUN parameters ([05c02db9](https://github.com/dracut-ng/dracut/commit/05c02db994ca322371a40695a3cc223faa1c7258))
* **network-legacy:**  sanitize DHCP values in dhclient-script.sh ([11577739](https://github.com/dracut-ng/dracut/commit/11577739221ff38c1fd29abbba51a6c797376ed6))
* **network-manager:**  prevent command injection while parsing DHCP options ([589bef03](https://github.com/dracut-ng/dracut/commit/589bef03b7acb26124b32011d3e39552490ebca3))
* **nfs:**  rpc.statd binary is not required for NFSv4 ([d152163a](https://github.com/dracut-ng/dracut/commit/d152163aa4697438eca9ade3cb3fa9b2e0dd46f0))
* **nvmf:**
  *  parse json output from "nvme list-subsys" ([c2729e52](https://github.com/dracut-ng/dracut/commit/c2729e52b43b103deb10bd7a18a7371890d8b1cb))
  *  make network driver determination work without nbft$X ([21db5cb4](https://github.com/dracut-ng/dracut/commit/21db5cb4cbf91fe3f0d18e0b8c4fa8c6def5137e))
* **overlayfs-crypt:**  prevent eval injection in parse_overlay_opts() ([584e95be](https://github.com/dracut-ng/dracut/commit/584e95bea90cedd12d9190e9b09bb45e1aa26b08))
* **systemd-*:**  add new dlopen dependencies to modules lists ([7ef765d6](https://github.com/dracut-ng/dracut/commit/7ef765d658bc52fd300d7c9a220daad4220f62f1))
* **systemd-networkd:**
  *  use another name for the default .network file ([0d35650a](https://github.com/dracut-ng/dracut/commit/0d35650abff78c62208a894300ca16e4bd873dbf))
  *  escape values from DHCP options ([b456aee2](https://github.com/dracut-ng/dracut/commit/b456aee2fc61c47db0d9a408634820969e7359df))
  *  get DHCP options values from networkctl ([7c57b1cc](https://github.com/dracut-ng/dracut/commit/7c57b1cccd4100351da5258ac6a22e07608a5e85))
* **systemd-pcrextend:**  add missing systemd-pcr{nvdone,osseparator}.service ([e57ad524](https://github.com/dracut-ng/dracut/commit/e57ad5243415c3c6bb895156bc6fa85ff2ea277d))
* **systemd-tmpfiles:**  do not include tmpfiles configured in /etc ([73e9b649](https://github.com/dracut-ng/dracut/commit/73e9b649f525217c779abd71723b979fc385165b), closes [#1706](https://github.com/dracut-ng/dracut/issues/1706))
* **systemd-udevd:**  install systemd-udevd-varlink.socket ([4323cf07](https://github.com/dracut-ng/dracut/commit/4323cf072a936cad6690996b64c915462d3836cd))
* **tpm2-tss:**
  *  add missing 60-tpm2-id.rules ([5e133721](https://github.com/dracut-ng/dracut/commit/5e133721eeb9c17135958389b2cf029bbf9a9f7c))
  *  add missing systemd-tpm2-setup-early.service ([98d6a569](https://github.com/dracut-ng/dracut/commit/98d6a569aaf5f750550aeaf025f6c7f494f580d5))
* **usrmount:**  filter out subvolid option for btrfs ([26bafde3](https://github.com/dracut-ng/dracut/commit/26bafde32d12befac0703799c5190648a5a1b24b))
* **virtfs:**  move mount hook to pre-mount ([7e02a913](https://github.com/dracut-ng/dracut/commit/7e02a9134115d1b27faa186ac2d5702f2d42f2c7))

#### Performance

* **devicetree-firmware:**  do not call inst_multiple if there are no fw files ([c1cb94f0](https://github.com/dracut-ng/dracut/commit/c1cb94f082b8be2ba381772e56362c0699439a94))
* **dracut-systemd:**  drop ExecStart from oneshot shutdown service ([bb2f35cb](https://github.com/dracut-ng/dracut/commit/bb2f35cb0697ce188d9591e3d005f615cecb6534))
* **systemd-modules-load:**  remove duplicate paths from inst_multiple ([a1b9f9ec](https://github.com/dracut-ng/dracut/commit/a1b9f9ec923313c00576c7a5d60f29ee98adea57))
* **systemd-networkd:**  remove duplicate service from inst_multiple ([d2599468](https://github.com/dracut-ng/dracut/commit/d2599468e6dd69f2c4de5f2dba5152711e35dc7f))
* **systemd-sysctl:**  remove duplicate paths from inst_multiple ([40eae157](https://github.com/dracut-ng/dracut/commit/40eae15725721ee1e72fcac7b2fadea09c69cc89))
* **systemd-tmpfiles:**  do not install systemd-tmpfiles-clean.service ([ce430f1e](https://github.com/dracut-ng/dracut/commit/ce430f1e876983cce1f0cc96342c153abcf8320d))
* **udev-rules:**
  *  do not install the mtp-probe udev helper ([9f772844](https://github.com/dracut-ng/dracut/commit/9f772844f35483efe0a81e4123e7e089f22e8de5))
  *  do not install the hid2hci udev helper ([bc63ac2c](https://github.com/dracut-ng/dracut/commit/bc63ac2ccfeea07d6735648344eaf5a7d4838b8a))
  *  do not try to install fw_unit_symlinks.sh ([d0146924](https://github.com/dracut-ng/dracut/commit/d0146924467e888bad4b7f52b456fb2e938d4d5c))
  *  do not try to install create_floppy_devices ([55bf9202](https://github.com/dracut-ng/dracut/commit/55bf9202afbcaf4e8b3f8f7852273e8529afda18))
  *  do not try to install udev built-ins ([b82d7152](https://github.com/dracut-ng/dracut/commit/b82d7152e2b2cf17c94cd9783ea2833fea9d9967))
  *  do not try to install 59-scsi-sg3_utils.rules ([4c226acd](https://github.com/dracut-ng/dracut/commit/4c226acd2a486a6f582d6d4e9587c5c461842494))
  *  do not try to install 95-udev-late.rules ([5c227d40](https://github.com/dracut-ng/dracut/commit/5c227d4004f5e4e92035acac345a1a43a1e16dab))

#### Features

*   check shellcode to support busybox ([25bedc75](https://github.com/dracut-ng/dracut/commit/25bedc7528d9c1915c9a61e356a2c62433d03883))
* **Makefile:**  allow running syntax checks separately ([3a489b1c](https://github.com/dracut-ng/dracut/commit/3a489b1c1d3f3cc8141428b74e617eea7ce7e9d9))
* **base:**  add escape function implementing printf %q ([207c3397](https://github.com/dracut-ng/dracut/commit/207c339728eff81127469c2f6fe106447c781009))
* **chrony:**  introducing the chrony module ([4d64d0b9](https://github.com/dracut-ng/dracut/commit/4d64d0b99dd7267764272dbc4a210ccbda2db3db))
* **dracut:**
  *  add module to load Qualcomm ADSP module pre-udev ([647a685d](https://github.com/dracut-ng/dracut/commit/647a685d3567dcf42fde10e1ae258967441e3223))
  *  add parameter --nvmf-nbft-mode ([146927ce](https://github.com/dracut-ng/dracut/commit/146927ce81504da078b0e27b05b7b2786065ae51))
* **network-manager:**
  *  write info about NTP servers in dhcpopts file ([8b77df75](https://github.com/dracut-ng/dracut/commit/8b77df75931f20ab17c8054fdd354194ea3c289d))
  *  use escape to drop requiring bash ([9c7459bd](https://github.com/dracut-ng/dracut/commit/9c7459bde0e78dd2e1e14d35c5351ef627b1b1fc))
* **nvmf:**
  *  set rd.nvmf.nm=1 if NetworkManager 1.54 is detected ([97858467](https://github.com/dracut-ng/dracut/commit/97858467aa7e4555cdb74bda47c8e727f0da05c0))
  *  allow using system interface naming policy ([00df7431](https://github.com/dracut-ng/dracut/commit/00df743123776a171f4701bfdecd7dcb6ccfb793))
  *  add dracut.conf option nvmf_nbft_mode ([bc1f1405](https://github.com/dracut-ng/dracut/commit/bc1f1405061dc77843bd5154443bfdc654de0672))
  *  enable adapting to NBFT reconfiguration ([3ecd3048](https://github.com/dracut-ng/dracut/commit/3ecd304816b03c6f61ebbe4a1f0ca71b7226cece))
* **resume:**
  *  include in hostonly sloppy mode if supported by kernel ([0589c659](https://github.com/dracut-ng/dracut/commit/0589c65977287be79c22290e992df6bed3d657ec))
  *  add debug logs to check() ([03a5ea09](https://github.com/dracut-ng/dracut/commit/03a5ea09c3d308c344ce682fa7e5c424273db11a))
* **systemd:**  drop unnecessary dependency on libgcrypt ([0406aa64](https://github.com/dracut-ng/dracut/commit/0406aa64a788c63a0bb2fd9d60a2d3d2d96320cb))
* **systemd-networkd:**  write info about NTP servers in dhcpopts file ([96c9d5c4](https://github.com/dracut-ng/dracut/commit/96c9d5c4fa49cf9b0c82868db2f8aae218a73739))

#### Contributors

- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- Benjamin Drung <benjamin.drung@canonical.com>
- devkontrol <dev@kontrol.dev>
- Martin Wilck <mwilck@suse.de>
- Miao Wang <shankerwangmiao@gmail.com>
- Neal Gompa <neal@gompa.dev>
- Luca Boccassi <luca.boccassi@gmail.com>
- dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
- Alexander Tsoy <alexander@tsoy.me>
- Esat <saygina7@gmail.com>
- Frantisek Sumsal <frantisek@sumsal.cz>
- Hans de Goede <johannes.goede@oss.qualcomm.com>
- Icenowy Zheng <uwu@icenowy.me>
- Jihong Min <hurryman2212@gmail.com>
- Jo Zzsi <jozzsicsataban@gmail.com>
- Josh Poimboeuf <jpoimboe@kernel.org>
- Miao Wang <shankerwangmiao@users.noreply.github.com>
- Nadzeya Hutsko <nadzeya.hutsko@canonical.com>
- Pavel Valena <pvalena@redhat.com>
- Stuart Hayes <stuart.w.hayes@gmail.com>
- Vivian Wang <wangruikang@iscas.ac.cn>
- Zhang Hua <joshua.zhang@canonical.com>
- fiftydinar <65243233+fiftydinar@users.noreply.github.com>
- gomid4497 <rakeshw728@gmail.com>

dracut-111
=============

#### Performance

*   export DRACUT_ARCH globally ([c50c04b0](https://github.com/dracut-ng/dracut/commit/c50c04b00320e170ed77afac19c9753258fe398d))
* **systemd-sysext:**  do not attempt to install extension metadata ([25ffc0f0](https://github.com/dracut-ng/dracut/commit/25ffc0f0da253e49a68f3d5b85e8854a292483c2))

#### Features

*   derive systemd generator name dynamically from script ([6ff36870](https://github.com/dracut-ng/dracut/commit/6ff368706c06bb8608151d12ceee50c56f6bd733))
* **crypt-lib:**  introduce crypt-lib dracut module ([8a82565e](https://github.com/dracut-ng/dracut/commit/8a82565e364b915fa9578e4658312e9c3389de3f))
* **dmsquash-live:**  add busybox blkid compatibility ([7c0298a7](https://github.com/dracut-ng/dracut/commit/7c0298a779368e90c75e690c490415860483faad))
* **dracut:**
  *  add module to add fw files from DT firmware-name properties ([725fe30b](https://github.com/dracut-ng/dracut/commit/725fe30be562e9c5567137f1351ae8c5af0ed422))
  *  add a DRACUT_EXTRA_ARGS environment variable ([99738e52](https://github.com/dracut-ng/dracut/commit/99738e526b7e17ebc0e18bbf51037cb4d0d82304))
* **dracut-catimages.sh:**  move images directory from /boot to /var/lib ([6bfd026e](https://github.com/dracut-ng/dracut/commit/6bfd026ee164d6b2a5ba4a2b91ae9d0984e4a2f7))
* **overlayfs:**  support tmpfs size parameter in rd.overlay ([9740a99a](https://github.com/dracut-ng/dracut/commit/9740a99a5e1164db7d64c8bd602427f2239ad5e3))
* **overlayfs-crypt:**  add new encrypted persistent overlay support ([c74f8ac2](https://github.com/dracut-ng/dracut/commit/c74f8ac20500211edd02f4fa9acb17c07c1b3a38))
* **systemd-sysext:**  include systemd-{sys,conf}ext-sysroot services ([205415b5](https://github.com/dracut-ng/dracut/commit/205415b52f2e413780a86bc33784ee99f8ace4cf))
* **systemd-sysusers-service:**  systemd-sysusers.service module ([e0a7c9e2](https://github.com/dracut-ng/dracut/commit/e0a7c9e2f1bacd283419320166e5630503d8fc68))

#### Bug Fixes

*   disable hostonly_cmdline for Gentoo by default ([6c772faa](https://github.com/dracut-ng/dracut/commit/6c772faab608c078a1aa3ff3fa509679629485ff))
*   explicitly set and document Gentoo defaults ([86dae808](https://github.com/dracut-ng/dracut/commit/86dae8081027e3461a49999d63938561eb2ed662))
*   avoid arguments for dot commands ([045e9e30](https://github.com/dracut-ng/dracut/commit/045e9e306f6d8a9359c1e9265200d9d4b6c85ec3))
*   set DRACUT_TMPDIR before using it in dlog_init() ([56ba87ad](https://github.com/dracut-ng/dracut/commit/56ba87ad233adc8f6ce4b13218efd1e18c297035))
* **SYSTEMD-IMPORT:**  remount /sysroot with dev and suid flags ([32d12606](https://github.com/dracut-ng/dracut/commit/32d1260667d0bea64573bf23ffa8f5c23c631d2a))
* **base:**  move initrd.target.wants symlink creation to wait_for_dev ([d971230a](https://github.com/dracut-ng/dracut/commit/d971230a5a8c0079ac342d4b5e03bf8b5496e6b1))
* **crypt:**
  *  use systemd generator for setting the timeout ([951be8ce](https://github.com/dracut-ng/dracut/commit/951be8ce50d08b6dc8cf6b474c2bfb632048df9a))
  *  use -d instead of -f to check for $NEWROOT/proc directory ([57edbca1](https://github.com/dracut-ng/dracut/commit/57edbca16f6a819c2f12058a8f1ea609e2a9c7ef))
  *  honor timeout setting when using UUID, LABEL, etc ([89d5f2cb](https://github.com/dracut-ng/dracut/commit/89d5f2cb7e9d31ac7d8ab1ba6b5757cc2c9ec403))
* **dbus:**  remove After/Requires from dbus service/socket ([6102479e](https://github.com/dracut-ng/dracut/commit/6102479e83f1c3f3e57f0a46a90494489dfeaa9c))
* **dmsquash-live:**
  *  correct det_img_fs implementation ([f3d81b8d](https://github.com/dracut-ng/dracut/commit/f3d81b8d968762896d60e2061a6c2b7d400fc2d0))
  *  load kernel module before mount ([9ca2cec1](https://github.com/dracut-ng/dracut/commit/9ca2cec17ab21049b81ad411fb18604faddd58b3))
* **dracut:**
  *  do not record parameters that do not change the initrd ([44a15508](https://github.com/dracut-ng/dracut/commit/44a15508c0bf77e836c7745c1ec3be48b2d6559b))
  *  remove leading space from recorded arguments ([0a62cc4a](https://github.com/dracut-ng/dracut/commit/0a62cc4a27568e1b19b4e9c6d86bbc9cf0693884))
  *  inst_libdir_file() does not have a -o option ([a8b2a995](https://github.com/dracut-ng/dracut/commit/a8b2a995272d1e63494c1b8b74a908db5137a1b6))
  *  determine hostonly_cmdline after hostonly setting ([6cfafda4](https://github.com/dracut-ng/dracut/commit/6cfafda44a70c9907e8af0a11dba95c36896d369))
  *  properly detect kernel version with --sysroot ([d19f65d1](https://github.com/dracut-ng/dracut/commit/d19f65d17e0b8d5cc7595339b3a83092e8d760ed))
  *  enable hostonly_cmdline in hostonly mode again ([04af3c09](https://github.com/dracut-ng/dracut/commit/04af3c097797d102934bc7ec666ed8eef00af9bb))
  *  remove unused dracut_no_switch_root ([f61865ce](https://github.com/dracut-ng/dracut/commit/f61865ce5288c4876d5d32ad2e2e8ab0ab4bf3f0))
  *  remove udevrulesconfdir variable ([d867f00d](https://github.com/dracut-ng/dracut/commit/d867f00d87b7ccc2738901a73f3d7bc20ed30989))
  *  remove unused host_fs_all ([8ef39d08](https://github.com/dracut-ng/dracut/commit/8ef39d0802daade93d7f578cfd6bb3bfc92a139c))
* **dracut-catimages.sh:**
  *  do not create overlay image without image directory ([66336959](https://github.com/dracut-ng/dracut/commit/66336959b8e225499d1868888ec31fa881b8f4b5))
  *  do not call shift for options without arguments ([e46ac221](https://github.com/dracut-ng/dracut/commit/e46ac221e2ac7d5a3f60e0f66173ea585ef98710))
  *  log proper missing images directory ([1d78fd0e](https://github.com/dracut-ng/dracut/commit/1d78fd0e0a014addd7c6fe56c42d1c044628fa46))
* **dracut.sh:**  use printf instead of echo in mark_hostonly ([002f0901](https://github.com/dracut-ng/dracut/commit/002f09013ef3c9c98b7ec89ed5e35a7fa8f161e6))
* **functions:**  prevent find_binary from dropping last PATH element ([d1c3b6ff](https://github.com/dracut-ng/dracut/commit/d1c3b6ffed3a07e7048a2cd8c86fc553e5fcddf4))
* **kernel-modules:**  install mmc drivers on all architectures ([18cfdccd](https://github.com/dracut-ng/dracut/commit/18cfdccd346f14dde56663dc660ccd90b62db358))
* **kernel-modules-export:**  use return instead of exit in pre-pivot hook ([9c6fce6a](https://github.com/dracut-ng/dracut/commit/9c6fce6a7190d90241e806c8f5646e57d0f46715))
* **man:**  inst_libdir_file() does not have a -o option ([8cdd3675](https://github.com/dracut-ng/dracut/commit/8cdd36756f14f2b30d2540f780e20e833792850d))
* **memdisk:**  use return instead of exit in cmdline hook ([ce9337e4](https://github.com/dracut-ng/dracut/commit/ce9337e43e2b427f06162596d258ea37dce3064d))
* **network-legacy:**  add input validation to RFC 3442 route parser ([4497dafb](https://github.com/dracut-ng/dracut/commit/4497dafbf09e54827d28de06fd93f63f66c2efda))
* **overlayfs:**  unmount NEWROOT before mounting overlay ([eef62a5b](https://github.com/dracut-ng/dracut/commit/eef62a5b40988d66f4759465f6952e02f67c0f70))
* **overlayfs-crypt:**  make module-setup.sh executable ([29af32af](https://github.com/dracut-ng/dracut/commit/29af32affe4ffb29db262518d3a7fc86631b5589))
* **ppcmac:**  use return instead of exit in pre-udev hook ([5d81516b](https://github.com/dracut-ng/dracut/commit/5d81516ba5591ed0d8b63905ccaafadc0745bb8f))
* **shutdown:**  warning printed unconditionally ([7f5c88cf](https://github.com/dracut-ng/dracut/commit/7f5c88cf5b8604a601421a89777d859e217297a3))
* **squash-lib:**  inst_libdir_file() does not have a -o option ([e4a2555e](https://github.com/dracut-ng/dracut/commit/e4a2555e61d5041747357e7350a5edcea2acd407))
* **syslog:**  use return instead of exit in initqueue/online hook ([ce808b75](https://github.com/dracut-ng/dracut/commit/ce808b750a02b8a9d6495eb7fa504d3265226d04))
* **systemd-cryptsetup:**
  *  only filter out modules for strict hostonly ([c94b1b16](https://github.com/dracut-ng/dracut/commit/c94b1b16dc03d47c156dfdaf3c73700346218a01))
  *  load libcryptsetup via dlopen ([60a5e034](https://github.com/dracut-ng/dracut/commit/60a5e034604d9740d460881ff1d03794b9a9b08a))
* **systemd-networkd:**
  *  create /run/systemd/network if missing ([93465460](https://github.com/dracut-ng/dracut/commit/93465460dc0412d13d30e19184509231978d3a44))
  *  check if units exist before enabling them ([eed94b22](https://github.com/dracut-ng/dracut/commit/eed94b22ec59a3acebfa7df4ad1b7643a620aa75))
* **systemd-pcrextend:**  add NVPCR definition files ([e6b27fd2](https://github.com/dracut-ng/dracut/commit/e6b27fd2bff886720a1e6295766ee22d07f37d9a))
* **systemd-repart:**  load libfdisk via dlopen ([0a6e83db](https://github.com/dracut-ng/dracut/commit/0a6e83db292fe63f033d8222c02d3a25324f3c4b))
* **systemd-sysext:**
  *  add dependency to systemd-veritysetup ([87f4ffd2](https://github.com/dracut-ng/dracut/commit/87f4ffd2f153b3cf026804bf483e5c13dcb54752))
  *  install kernel modules for common disk images ([70807834](https://github.com/dracut-ng/dracut/commit/70807834703991e9e0c4597e38dc331d87431d05))
* **systemd-veritysetup:**  validate dm-verity signatures in userspace ([f20fd63e](https://github.com/dracut-ng/dracut/commit/f20fd63e6e9e2a89bea52d1bfb793c588a8e1d7e))
* **zipl:**  repair parsing of rd.zipl=LABEL|UUID|...= ([75731188](https://github.com/dracut-ng/dracut/commit/75731188fde19407d8088835041cd5ce80db77af))
* revert: systemd requires cryptsetup targets installed earlier ([802c7393](https://github.com/dracut-ng/dracut/commit/802c7393aa5a2407db68e1194a71df3251fd2605))

#### Contributors

- Benjamin Drung <benjamin.drung@canonical.com>
- Jo Zzsi <jozzsicsataban@gmail.com>
- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
- Nadzeya Hutsko <nadzeya.hutsko@canonical.com>
- Nowa Ammerlaan <nowa@gentoo.org>
- Vitaly Kuznetsov <vkuznets@redhat.com>
- Andrey Prokopenko <9478806+terem42@users.noreply.github.com>
- Elias <105282627+elherrmann@users.noreply.github.com>
- Fabian Vogt <fvogt@suse.de>
- Hans de Goede <johannes.goede@oss.qualcomm.com>
- Hector Cao <hector.cao@canonical.com>
- Matéo Pourrier <mateo.pourrier@smile.fr>
- Mewt R <25155631+MewtR@users.noreply.github.com>
- Sidharth Sankar <sidstuffhere@gmail.com>

dracut-110
=============

#### User notes

The `systemd-pcrphase` module has been renamed to `systemd-pcrextend` to align with upstream systemd changes.

The following modules are new for this release:

- `memdisk`
- `systemd-import`


#### Distributor notes

The separate `dracut-version.sh` has been removed.
In order to set the distributor version (e.g. when packaging dracut), set `DRACUT_FULL_VERSION` when calling `make`.
When packaging an unreleased snapshot version, please also set `DRACUT_MAIN_VERSION` to a version string identifying the base version + commit.

As an example, when packaging a release of dracut as an RPM, use an invocation like so:

```specfile
%build
%make_build DRACUT_FULL_VERSION="%{version}-%{release}"

%install
%make_install DRACUT_FULL_VERSION="%{version}-%{release}"
```


#### Bug Fixes

*   avoid leading spaces in systemd units ([68cd066c](https://github.com/dracut-ng/dracut/commit/68cd066c674b35cd0db854ce32c17156623c6506))
*   grammatical errors ([2b992cae](https://github.com/dracut-ng/dracut/commit/2b992cae1bd3193fb214a862be7b5a1ccabf1d39))
* **Makefile:**
  *  broken symlink in dracut config examples ([c30fdf0f](https://github.com/dracut-ng/dracut/commit/c30fdf0f27398fdd3bf625028b3bcb50b802aac0))
  *  improve support for shfmt v3.8.0+ ([96d95db4](https://github.com/dracut-ng/dracut/commit/96d95db4ffce45303a7eed831d807ece02a530dd))
  *  correct path for man pages for service files ([a18fc183](https://github.com/dracut-ng/dracut/commit/a18fc1834a2bb5ae8ebc02f9faae6fb666b207a6))
* **base:**  ensure that /run survives switch_root ([b9ecf13f](https://github.com/dracut-ng/dracut/commit/b9ecf13f7f9c66ce58bc410da5e00da0ed982cc9))
* **cpio:**  archive correct minor numbers ([dca4a403](https://github.com/dracut-ng/dracut/commit/dca4a4031d9f9736f7a3389a7ac5c01ce84dc7d8))
* **crypt-gpg:**  support missing /etc/dracut.conf.d ([786e8f27](https://github.com/dracut-ng/dracut/commit/786e8f276b4ad6394cafdbe7339d9a2a04e53784))
* **dm:**  add explicit rootfs-block dependency ([5e7e4cd3](https://github.com/dracut-ng/dracut/commit/5e7e4cd330da3e99fc2142e5f79297725729cd72))
* **dmsquash-live-autooverlay:**
  *  check that parted is present ([3290d186](https://github.com/dracut-ng/dracut/commit/3290d18615f3124d2da530f3937857b7e4d0b215))
  *  re-read partition table after creation ([99d25ea0](https://github.com/dracut-ng/dracut/commit/99d25ea0f81881c5a5eeada00d2ee7e08c28c69c))
* **dracut:**
  *  also check libraries when resolving lazy ([9becd78c](https://github.com/dracut-ng/dracut/commit/9becd78c0882f55cf1158993bd68be472b8a8793))
  *  move libdirs to dracut-functions.sh ([6fe23c38](https://github.com/dracut-ng/dracut/commit/6fe23c38b49b6468a109284398e54fd592df3758))
  *  move defining DRACUT_LDCONFIG to dracut-functions.sh ([294b3583](https://github.com/dracut-ng/dracut/commit/294b35834974b85c54281b145fa8ae006b276783))
  *  remove trailing null characters from SBATs when building UKIs ([785fbf8b](https://github.com/dracut-ng/dracut/commit/785fbf8b6ce6553823b454ec47d2e7276017e3f7))
  *  use proper dracut logging when possible ([2298980b](https://github.com/dracut-ng/dracut/commit/2298980b5c771621dc8e27bf11146c4c069b743e))
  *  ensure that inst is called after DRACUT_NO_XATTR is computed ([1e504843](https://github.com/dracut-ng/dracut/commit/1e5048433776abb90ba349c07c1a9624426c03df))
  *  move comment back to related dracut_args variable ([01efc845](https://github.com/dracut-ng/dracut/commit/01efc8452d410993dbbce84d3c644483fbf60c02))
  *  source dracut-functions.sh before calling dwarning ([8552a0f4](https://github.com/dracut-ng/dracut/commit/8552a0f443ffeacd6529f0c86896f64d1b646fbe))
  *  ignore shellcheck SC2329 in addition to SC2317 ([d82bff14](https://github.com/dracut-ng/dracut/commit/d82bff144ef58a90ce02b68db790b52796f864c9))
  *  ignore failing find_binary dracut-install ([26c55932](https://github.com/dracut-ng/dracut/commit/26c5593222ff8521104bed08d9f3a4264ff0bf40))
  *  remove newlines from libdirs variable ([62d71056](https://github.com/dracut-ng/dracut/commit/62d710568f1c6129a97487b5ef2666b70c61c9fc))
  *  --printconfig does not work without --force ([00bc4fc2](https://github.com/dracut-ng/dracut/commit/00bc4fc27d689a954ceec521490e6a2507524c06))
  *  shellcheck SC2086 ([c47e8910](https://github.com/dracut-ng/dracut/commit/c47e8910877b245e18f4da62b9abf606ba51e111))
* **dracut-functions:**  check for kmod ([4458505e](https://github.com/dracut-ng/dracut/commit/4458505ee98248a183c63b219e98906713644dea))
* **dracut-init:**  do not set DRACUT_KERNEL_MODALIASES for --no-kernel ([902bd6ce](https://github.com/dracut-ng/dracut/commit/902bd6ce6279de63f4dbcab5f8059b193339645e))
* **dracut-install:**
  *  resolve dependencies even if not executable ([fff546a2](https://github.com/dracut-ng/dracut/commit/fff546a27ea45f051adb64ce665f1a171dbfca6d))
  *  build with -Werror=discarded-qualifiers ([f2d0e638](https://github.com/dracut-ng/dracut/commit/f2d0e6386102428cede35d51922b4b275d9a2e64), closes [#1877](https://github.com/dracut-ng/dracut/issues/1877))
* **dracut-logger:**
  *  do not require debug to be defined ([aa94df95](https://github.com/dracut-ng/dracut/commit/aa94df953537ca5c883e51f244f5e878b24f6b2d))
  *  disable kernel logging if /dev/kmsg is not writable ([49c32f9f](https://github.com/dracut-ng/dracut/commit/49c32f9f05643ca41a6b1685e03a28db8c9a92e3))
  *  allow dlog_init to print multiple errors ([6aa1abf3](https://github.com/dracut-ng/dracut/commit/6aa1abf360c8bbe00cdd0aa9204103b55f552ffc))
  *  do not export maxloglvl and syslogfacility ([f7fd8d3f](https://github.com/dracut-ng/dracut/commit/f7fd8d3f083b75a7a373cb335320009e69fdaaae))
* **dracut-systemd:**
  *  do not error out with new root= options handled by systemd ([529bf27d](https://github.com/dracut-ng/dracut/commit/529bf27d48fa7170cc5384b8b8fb3753ae4da99e))
  *  use expected PS1 in the emergency shell ([ccd096a1](https://github.com/dracut-ng/dracut/commit/ccd096a15d6a4f64cfdc14f890b518239efc18bf))
* **dracut.conf.d:**  demote uki-virt to CI only ([39e7cf1f](https://github.com/dracut-ng/dracut/commit/39e7cf1f63b0213e18a4c12f688620fc8f11e515))
* **functions:**  do not use path escapes for non-paths ([c04ee829](https://github.com/dracut-ng/dracut/commit/c04ee82917c21b9cf1a2fd23c40339df1da475f1))
* **i18n:**  remove Gentoo workaround that is no longer needed ([53ed2794](https://github.com/dracut-ng/dracut/commit/53ed2794084bfee92d58477f81fb796fb20e896c))
* **livenet:**  correct check for deprecated rd.live.overlay.overlayfs ([3f3c377b](https://github.com/dracut-ng/dracut/commit/3f3c377bbe58f4e05358492537f777ed2b25546d))
* **man:**
  *  avoid bold italic text ([fd090e10](https://github.com/dracut-ng/dracut/commit/fd090e103700f099f77ccb2208d6a31db2f05f39))
  *  avoid nesting italic in bold text ([cdd3daac](https://github.com/dracut-ng/dracut/commit/cdd3daaccb40235e1bf1b44903047068a21362db))
* **multipath:**  always forcefully load multipath modules ([5ace3b01](https://github.com/dracut-ng/dracut/commit/5ace3b018a7b662873cad38d6bc95a41cd3979fe))
* **nfs:**
  *  simplify DRACUT_CP arguments to increase portability ([703c8c19](https://github.com/dracut-ng/dracut/commit/703c8c191d75060e3f97e050e63f3fb2b6ae059c))
  *  do not execute logic in nfs hooks if netroot is not nfs ([bf29f4b7](https://github.com/dracut-ng/dracut/commit/bf29f4b79aee9771800dffe78857014970be117e))
  *  set the default group of the rpcbind user to the state dir ([90dc4436](https://github.com/dracut-ng/dracut/commit/90dc443626ca9f61277159686e558502ebbc0845))
* **overlayfs:**  make overlayfs-lib.sh executable ([186d15df](https://github.com/dracut-ng/dracut/commit/186d15df636ce69e8cd630b3108077abc97065fe))
* **plymouth:**  avoid warning if /etc/plymouth/plymouthd.conf is not present ([45d560bb](https://github.com/dracut-ng/dracut/commit/45d560bbb39c165781d3e42989212574982ddd6d))
* **release:**
  *  use correct argument for head(1) to split header out ([5f3c23aa](https://github.com/dracut-ng/dracut/commit/5f3c23aa8683a7db810c31aad8189995b6ad10f1))
  *  use the correct variable to set the new project version ([a9114d49](https://github.com/dracut-ng/dracut/commit/a9114d4921920438c95ef17805b2edc300a14985))
  *  use correct arguments for head(1) and tail(1) calls ([77c0d577](https://github.com/dracut-ng/dracut/commit/77c0d5774b02ee3b5972899766fa1fe74d645fd3))
  *  only install clog-cli if it isn't already installed ([d04db3be](https://github.com/dracut-ng/dracut/commit/d04db3be727eed6be4c11226696036d518908494))
* **systemd:**  only install systemd-coredump with systemd-coredump dracut module ([a8268a4d](https://github.com/dracut-ng/dracut/commit/a8268a4df142517674244cd208e067df06b978e8))
* **systemd-cryptsetup:**  increase ordering to resolve regression ([d7bdbbb7](https://github.com/dracut-ng/dracut/commit/d7bdbbb702abcd9c141decd0160284ad22a8b253))
* **systemd-networkd:**
  *  ensure zzzz-dracut-default.network cleanup ([da3353f0](https://github.com/dracut-ng/dracut/commit/da3353f022cc7b930dd532e2f1e06af4e86999d3))
  *  install and enable systemd-networkd-resolve-hook.socket ([84c05fc6](https://github.com/dracut-ng/dracut/commit/84c05fc661fa2ec01cfb341e73569542d46938d7))
* **systemd-pcrphase:**  do not print an error if an optional binary is not found ([7f45703d](https://github.com/dracut-ng/dracut/commit/7f45703de9b2d67ffebb3b9d0847b51b32d6479c), closes [#2094](https://github.com/dracut-ng/dracut/issues/2094))
* **systemd-portabled:**  do not call portablectl ([2a0b1f4e](https://github.com/dracut-ng/dracut/commit/2a0b1f4ebbfc5233f190df00640d790ebdb5b44d))
* **test/DMSQUASH:**  zero overlay partition on reset ([ca2335fb](https://github.com/dracut-ng/dracut/commit/ca2335fbd610d5918bb178da6b70d8617d3e44d5))
* **tpm2-tss:**  add tss user/group in addition to sysusers config ([28adf6f9](https://github.com/dracut-ng/dracut/commit/28adf6f91cf7e294799e5a8b73b5937644c8cde9))

#### Performance

* **dracut:**
  *  remove duplicate export libdirs ([329344bc](https://github.com/dracut-ng/dracut/commit/329344bcc2774222345d854d62b034646322bfbd))
  *  unset threecpio_help_output after usage ([724da6ef](https://github.com/dracut-ng/dracut/commit/724da6ef940e18d61da5a50fc7d1d7a0af4a2b0a))
  *  re-use cached 3cpio --help output ([e9c3e0bf](https://github.com/dracut-ng/dracut/commit/e9c3e0bf4a3822132106423ea59d9c1d04a807c1))
  *  replace grep by bash pattern matching ([ddd6a7d3](https://github.com/dracut-ng/dracut/commit/ddd6a7d3df1c4c5b69d177649279fb82532c2e8a))
* **nfs:**
  *  do not source /lib/nfs-lib.sh twice ([0b086e9f](https://github.com/dracut-ng/dracut/commit/0b086e9fc82d7957ada7a60e327d41c8ff5ea5a7))
  *  remove references to old rpcbind state dir ([2f49cbbe](https://github.com/dracut-ng/dracut/commit/2f49cbbe1503926913d7547d713aad158aaa86a8))
* **resume:**
  *  remove unreachable code ([f1ccdaa3](https://github.com/dracut-ng/dracut/commit/f1ccdaa34b640f4872facc2f2830b7d05dfbd5f3))
  *  do not search cmdline options in /etc/cmdline{,.d} ([67e8c3d5](https://github.com/dracut-ng/dracut/commit/67e8c3d51ef8f5ac0b3a4c8148e01059b01bc863))
  *  do not attempt to install systemd-hibernate-resume@.service ([ddb46200](https://github.com/dracut-ng/dracut/commit/ddb46200216932ec59eff170396afc5a704177ce))

#### Features

*   memdisk dracut module ([f1d6a0bc](https://github.com/dracut-ng/dracut/commit/f1d6a0bc8df8e4f701768a788faac7fbcb94ebe9))
*   merge rd.overlayfs into rd.overlay ([d90c59bb](https://github.com/dracut-ng/dracut/commit/d90c59bb28e80a8a3d6e14ecf499aeba00896a15))
*   replace DRACUT_RESOLVE_DEPS by !DRACUT_RESOLVE_LAZY ([1d302268](https://github.com/dracut-ng/dracut/commit/1d302268ae1a60fccefd81a9f6cd71d2c95d8d2c))
*   rename rd.overlayfs.readonly to rd.overlay.readonly ([bcefa9d0](https://github.com/dracut-ng/dracut/commit/bcefa9d0a4acd34723bcb5438d7c5ff30932a10e))
*   warn in case 3cpio is present but not suitable ([dbd9f0ee](https://github.com/dracut-ng/dracut/commit/dbd9f0ee2c624e592a74b60080977b01307655c5))
*   rename rd.live.overlay to rd.overlay ([d6872bbd](https://github.com/dracut-ng/dracut/commit/d6872bbdf344170afa7bf4568f4a7366a8277fb9))
*   move DRACUT_VERSION from dracut-version.sh into dracut.sh ([d5e985d4](https://github.com/dracut-ng/dracut/commit/d5e985d40e7f8e3235b5cc0d7f068d336908a208))
*   add yamllint config ([55ed61f2](https://github.com/dracut-ng/dracut/commit/55ed61f2920c4aa029b542455e0350d15219ccaa))
*   always preserve file ownership ([24838e08](https://github.com/dracut-ng/dracut/commit/24838e0861826b842626a403e8cebadbc20d3dbd))
*   remove rev_lib_symlinks ([9d668b20](https://github.com/dracut-ng/dracut/commit/9d668b2006eb21cf41e24fc4c987095cc1c6059c))
*   remove inst_any ([d5571c91](https://github.com/dracut-ng/dracut/commit/d5571c919ad3a5bee024119e5efa88bb23c90e46))
*   source dracut-logger.sh from dracut-functions.sh ([ffc10b06](https://github.com/dracut-ng/dracut/commit/ffc10b06225f2a1fcf96fe20f410081411c54581))
*   remove unused and undocumented argument ([b8651e7b](https://github.com/dracut-ng/dracut/commit/b8651e7b1a73792458bc4c15c293337f5d856393))
*   add header comment to units created by systemd generators ([c80025d6](https://github.com/dracut-ng/dracut/commit/c80025d6e1a73eb0f881e349b2f47edaa27a3a9a))
*   rename rd.live.overlay.overlayfs to rd.overlayfs ([b77ae7eb](https://github.com/dracut-ng/dracut/commit/b77ae7eb8523da696fcb0f48a747ac22bdc9eb31))
* **Makefile:**  do not install network-legacy by default ([30d121b1](https://github.com/dracut-ng/dracut/commit/30d121b1bd4ad2fb26ea72e1b0d5581663179882))
* **base:**  support cmdline options in /run/initramfs/cmdline.d ([bac8b3da](https://github.com/dracut-ng/dracut/commit/bac8b3da6d8094d51b1cb4c6bb183e22cb001f12))
* **cpio:**  zero device major/minor numbers ([0bdecd92](https://github.com/dracut-ng/dracut/commit/0bdecd925fbaebebfea96af97a74257fdbf13af4))
* **dmsquash-live:**  allow booting from compressed ostree filesystems ([69a43970](https://github.com/dracut-ng/dracut/commit/69a43970015e5b8c5336b13b4f0355d3cb95e7fb))
* **dracut:**
  *  introduce additional hooks locations ([04d5e294](https://github.com/dracut-ng/dracut/commit/04d5e2944e1b1a85a945910995cb8df00d983a7c))
  *  allow hostonly mode if /sys /proc or /run is missing ([399e555f](https://github.com/dracut-ng/dracut/commit/399e555f9e870f4301c42d38cab244513caf7c5f))
  *  expose determine_kernel_image as a public function ([dd45cbff](https://github.com/dracut-ng/dracut/commit/dd45cbff0f588587cf845746b8d707dda7e2566f))
  *  add busybox support for 3cpio and enhanced_cpio ([b6877562](https://github.com/dracut-ng/dracut/commit/b6877562faeebd58ac503635edfad371b0c72264))
  *  drop unreachable code for dracutbasedir/initdir ([71d51e72](https://github.com/dracut-ng/dracut/commit/71d51e7221bc53ec90fb3ebf2cfe1240cda38763))
  *  disable xattr when creating cpios ([941b18d0](https://github.com/dracut-ng/dracut/commit/941b18d0f2536be860142e4a260aefa7aa5b4a06))
  *  print $uefi with --printconfig ([f235dcb7](https://github.com/dracut-ng/dracut/commit/f235dcb7e21a0a234bb70fab7705df417dd7a0ab))
  *  add support for --ukify, --no-ukify ([7ec5fbbe](https://github.com/dracut-ng/dracut/commit/7ec5fbbed4e39793859136c34cbbf9779fae536e))
  *  always check DRACUT_INSTALL being executable ([886725eb](https://github.com/dracut-ng/dracut/commit/886725ebc029a7275d7aefdb0f0add8cc81386b2))
  *  print $initrdname with --printconfig ([71a713bb](https://github.com/dracut-ng/dracut/commit/71a713bb2834f1994b226c7877dd8a0ef858928d))
* **dracut-systemd:**  preserve the content of /var/lib/systemd ([fd370b39](https://github.com/dracut-ng/dracut/commit/fd370b393e319e59b44b611e5fe28de52615d516))
* **gentoo:**  introduce a distro config file to default out of ukify ([918d54c1](https://github.com/dracut-ng/dracut/commit/918d54c174876fa2347ffa5be22d663df85b933e))
* **livenet:**  support root=http:* as alias for root=live:http:* ([7555aca3](https://github.com/dracut-ng/dracut/commit/7555aca320cb1266bcd2195ff07c860131d6df5e))
* **lvm:**  match host lvm recovery installation ([4fd5d2f3](https://github.com/dracut-ng/dracut/commit/4fd5d2f3a83f44085dece28a836a94f71edbafc2))
* **network-manager:**  add systemd generator if available ([b6329a08](https://github.com/dracut-ng/dracut/commit/b6329a088e2c49ee749361a1401e98380478da26))
* **no-xattr:**  no longer support no-xattr config ([8a915c95](https://github.com/dracut-ng/dracut/commit/8a915c95f4e003449a8d69d62c2f5200d619db49))
* **overlayfs:**  add persistent device overlay support ([716fd4ff](https://github.com/dracut-ng/dracut/commit/716fd4ffc969c3418fb6c8ba224b6d879e6f76b7))
* **pcsc:**  add openSUSE support ([254185a6](https://github.com/dracut-ng/dracut/commit/254185a69080d7e6568e995de5d3a5648e0c078e))
* **qemu-net:**  auto-add qemu-net if net-lib and qemu included ([94b21ab3](https://github.com/dracut-ng/dracut/commit/94b21ab38fa50fc0e789f0bd2b76cead5da3fd10))
* **systemd:**  install new dlopened libraries ([1ae49bf5](https://github.com/dracut-ng/dracut/commit/1ae49bf5d91669b27907953c1975754a9aada8aa))
* **systemd-import:**  introducing the systemd-import module ([9297137f](https://github.com/dracut-ng/dracut/commit/9297137f8d6c1eabe75cac79d7c3e81a15e4e990))
* **systemd-pcrphase:**  rename to systemd-pcrextend ([a4a34611](https://github.com/dracut-ng/dracut/commit/a4a34611a54f185b2f8269b7b5da2442c34e448f))
* **tpm2-tss:**  add openSUSE support ([66279611](https://github.com/dracut-ng/dracut/commit/66279611ec46e50e44298698ecc905e4548a8b2e))
* **virtfs, virtiofs:**  auto-add dracut module if qemu included ([f77b1c08](https://github.com/dracut-ng/dracut/commit/f77b1c08be5eff3869b38b02d1c06f583afb1d64))

#### Contributors

- Benjamin Drung <benjamin.drung@canonical.com>
- Jo Zzsi <jozzsicsataban@gmail.com>
- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- Nadzeya Hutsko <nadzeya.hutsko@canonical.com>
- Vitaly Kuznetsov <vkuznets@redhat.com>
- dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
- Neal Gompa <neal@gompa.dev>
- David Disseldorp <ddiss@suse.de>
- Brian C. Lane <bcl@redhat.com>
- Hongxu Jia <hongxu.jia@windriver.com>
- Jens Schmidt <farblos@vodafonemail.de>
- Li Tian <litian@redhat.com>
- Louis Narvaez <lnarvaez@redhat.com>
- Luca Boccassi <luca.boccassi@gmail.com>

dracut-109
=============

#### Performance

*   improve logger efficiency ([fd685905](https://github.com/dracut-ng/dracut/commit/fd685905a210bf5ba3933a9ac0491ce08993c659))

#### Features

*   dracut.sh: try $STRIP for $strip_cmd first ([862248dc](https://github.com/dracut-ng/dracut/commit/862248dcf1aa61e33f1a58fe3cf06c7d495e3180))
* **Makefile:**
  *  filter out warpclock on S390(x) systems ([287c4f66](https://github.com/dracut-ng/dracut/commit/287c4f664046e2c6d1c15b43ac8d9cbc4e1007e6))
  *  filter out s390 specific dracut modules ([fe6c4702](https://github.com/dracut-ng/dracut/commit/fe6c47025516fe9705fa0fb621b381ce85d5127c))
  *  introduce distclean target ([bb02f40a](https://github.com/dracut-ng/dracut/commit/bb02f40a7e9abcf03ded948aba72473de103cec3))
  *  set Dracut version on install ([86d1d086](https://github.com/dracut-ng/dracut/commit/86d1d08636fbcc6b7e012423f003d2440b07d23a))
* **configure:**  autoconfigure configprofile ([eada0fb9](https://github.com/dracut-ng/dracut/commit/eada0fb9ccd5578e1faf409fc3d34522bec425c0))
* **debian.conf:**
  *  default to initrd.img-${kernel} on Debian/Ubuntu ([5748845e](https://github.com/dracut-ng/dracut/commit/5748845ec8815d8ddb3032ff9ae0f6a58f5a34c0))
  *  add i18n_vars for Debian/Ubuntu ([c3078914](https://github.com/dracut-ng/dracut/commit/c3078914ddd9384106332ba8b672932a63573471))
* **dracut:**
  *  add support for /run/initramfs/dracut.conf.d ([82cd3d37](https://github.com/dracut-ng/dracut/commit/82cd3d3726db25a39b26b5039fcb76cc414e6b89))
  *  support setting compression level separately ([ebb7d787](https://github.com/dracut-ng/dracut/commit/ebb7d7872a59455929e0f24d8bec8639d939952f))
  *  support 3cpio for creating initrds ([2abaced7](https://github.com/dracut-ng/dracut/commit/2abaced74e688b6a807d9d7e7ddd070de632153e))
  *  print the computed configuration and exit ([8e24c4bf](https://github.com/dracut-ng/dracut/commit/8e24c4bf06850da1bc89022081b7e793548d9b0b))
  *  make hostonly the default ([24fb4c28](https://github.com/dracut-ng/dracut/commit/24fb4c28538b89c423a2d4e7c00ee6e016137f90))
* **dracut.conf.d:**  move examples into subdirectories ([d486a909](https://github.com/dracut-ng/dracut/commit/d486a909166a3245f99f3ab105c9540e81d669c6))
* **dracut.sh:**  output error message for --regenerate-all ([3d58272e](https://github.com/dracut-ng/dracut/commit/3d58272ea2b2d52bbb8b4ff23863b59a11874891))
* **fedora:**  switch to strict hostonly mode by default ([bc69bf4e](https://github.com/dracut-ng/dracut/commit/bc69bf4e3416791b50ad09d4b9d218e05b46c99d))
* **kernel-modules-export:**  make kernel modules from initramfs available ([21096b7e](https://github.com/dracut-ng/dracut/commit/21096b7e0e85532bc9ede2b4efce5f8454a3c02e))
* **lsinitrd:**  support 3cpio ([7b1612fc](https://github.com/dracut-ng/dracut/commit/7b1612fcdefff0ef1cff95ab79a1977a2722054a))
* **network-manager:**  remove support for ifcfg-rh ([63baa4e7](https://github.com/dracut-ng/dracut/commit/63baa4e7fd7ac7ee037f47a6e618bd3ce52cc3b0))
* **pcsc:**  add Debian/Ubuntu support ([1575aea4](https://github.com/dracut-ng/dracut/commit/1575aea44209d56ca0e80ca287b8f00f739e332d))
* **plymouth:**
  *  drop unused plymouth-populate-initrd ([d0a66a0f](https://github.com/dracut-ng/dracut/commit/d0a66a0f67ca70da188720532f48cd6a4754004e))
  *  do not check plymouth-populate-initrd for "nash" ([997be461](https://github.com/dracut-ng/dracut/commit/997be4618ef3d01f99dda0f400962ffdc5adf821))
  *  use simpledrm if Plymouth is configured to it ([7f41458b](https://github.com/dracut-ng/dracut/commit/7f41458b9d8350d08b0057e050d98b7a25c3e640))
* **qemu:**  install sd_mod driver ([2aaf5673](https://github.com/dracut-ng/dracut/commit/2aaf5673123d892426031ad43205ed0bfbd35915))
* **skipcpio:**  output additional CPIO information ([3841274d](https://github.com/dracut-ng/dracut/commit/3841274d3b63ed52bd6900dba3beb24ec2953bea))
* **systemd-networkd:**  do not require bash ([9f2e8da7](https://github.com/dracut-ng/dracut/commit/9f2e8da7fe79110d1c41f532a108a15dafb8569c))

#### Bug Fixes

*   line-buffer log output to /dev/kmsg ([cfc3fc61](https://github.com/dracut-ng/dracut/commit/cfc3fc618c526b83e22df694d7ac9d459ff36132))
*   typo in awk script in _do_dlog_batch_kmsglog ([f0d64b02](https://github.com/dracut-ng/dracut/commit/f0d64b02a3e1b754243d840823f10d3f4cf4550c), closes [#1803](https://github.com/dracut-ng/dracut/issues/1803))
*   make logging functions return 1 only on invalid log level ([5f9d2858](https://github.com/dracut-ng/dracut/commit/5f9d2858ecab67982c751045c3714eae9c60fbf7))
*   partial revert for hostonly sloppy mode ([ac8cb5e5](https://github.com/dracut-ng/dracut/commit/ac8cb5e5c16db52eadee5c3b32842780b09c5801))
*   place dracut generated cmdline conf files in the 10-49 range ([8680a553](https://github.com/dracut-ng/dracut/commit/8680a5530477808f5a79c587a361aebdfcdf9821))
*   ignore shellcheck SC2329 in addition to SC2317 ([c782a166](https://github.com/dracut-ng/dracut/commit/c782a1666655c2ff89fb035c071984896eb28ca8))
*   make sure final hostonly value is computed before reading it ([8d9887bd](https://github.com/dracut-ng/dracut/commit/8d9887bd773936cf3e42798dd26d70edd4213d4d))
* **74nvmf:**
  *  make sure autoconnect script is run at least once ([f879b04d](https://github.com/dracut-ng/dracut/commit/f879b04d5a243a34fffdd87902122afaceb1ba7a))
  *  only set netroot if it's yet empty ([1b11affd](https://github.com/dracut-ng/dracut/commit/1b11affd6d7e66038a6df6e45d408d59e87c418d))
  *  set root=nvmf ([585d7419](https://github.com/dracut-ng/dracut/commit/585d7419c7f9dec3fe3024aa03de415571856a9b))
* **Makefile:**
  *  correct filter condition for s390 specific modules ([cf735287](https://github.com/dracut-ng/dracut/commit/cf73528770c81942a9afe8197227d1706cf2b388))
  *  correct loop variable ([c2ed439a](https://github.com/dracut-ng/dracut/commit/c2ed439ab7c55235a3c0a9fc623ba206e8242968))
  *  exclude hidden directories from shellcheck part 2 ([a421ac07](https://github.com/dracut-ng/dracut/commit/a421ac07dbb7a7309761886b41f0d43d02be0359))
  *  exclude hidden directories from shellcheck ([7a65d1a1](https://github.com/dracut-ng/dracut/commit/7a65d1a1f3722475636159ccd0344525407da1ff))
  *  use install for installing files ([882923bc](https://github.com/dracut-ng/dracut/commit/882923bc16f214193adfa2d6df0781dfe4f7b952))
  *  remove the heuristic to determine fallback kernel version ([b97ab4a8](https://github.com/dracut-ng/dracut/commit/b97ab4a83612106796fd632574fccb219e3ea304))
* **UKI:**  explicitly specify '--uname' ([70466f56](https://github.com/dracut-ng/dracut/commit/70466f562734007c6036ddb2c69422bc8c46a823))
* **base:**
  *  set udev log level properly ([aae995ec](https://github.com/dracut-ng/dracut/commit/aae995ecf67ba2ef9d1c78e50427cfa0734b169d))
  *  silence error log if shadow does not exists ([55256afa](https://github.com/dracut-ng/dracut/commit/55256afa9ee8027ad0b801580e7580baf623e944))
* **btrfs:**  write cmdline in install() ([c7b11828](https://github.com/dracut-ng/dracut/commit/c7b1182870b58491056a34cedd5e9e01af219132))
* **cpio:**
  *  use mutex to avoid multi-threaded failures ([587e7646](https://github.com/dracut-ng/dracut/commit/587e764629f03c0b01851adb0d52eb8264a6c394))
  *  unit test regression from GNU cpio changes ([41b20165](https://github.com/dracut-ng/dracut/commit/41b201658d45b371f6126fe53d0523c41c63338f))
* **dbus, network-manager:**  make generic mode host independent ([2e14afe8](https://github.com/dracut-ng/dracut/commit/2e14afe8ddc89cf519504fae4e24d00ec5a8d90d))
* **debian:**
  *  no need to change permissions ([f14e3a25](https://github.com/dracut-ng/dracut/commit/f14e3a25a14b53854a2570f632767fbcfd62d08e))
  *  lower the ordering number for debian conf ([33a62941](https://github.com/dracut-ng/dracut/commit/33a62941595d2e25cfa17f2a01cb1b58d2aba8a1))
  *  remove Debian 12 support ([68b0f63f](https://github.com/dracut-ng/dracut/commit/68b0f63f6cd3da307ca161db01be50756add1335))
* **debian.conf:**  re-enable hostonly_cmdline ([3a85060c](https://github.com/dracut-ng/dracut/commit/3a85060cc7ce464b0d0693e5ec7024683aab6bf5))
* **dm,dmraid:**  shellcheck SC2268 ([b138454b](https://github.com/dracut-ng/dracut/commit/b138454b70b552d39dedddaee17be0d2c239a7b8))
* **dmsquash-live:**  install required stat binary ([46369b3b](https://github.com/dracut-ng/dracut/commit/46369b3bbd8b20bd33a7727a2ed4b779045ddd75), closes [#1780](https://github.com/dracut-ng/dracut/issues/1780))
* **doc:**  correct spelling mistake of recommended ([62be5b25](https://github.com/dracut-ng/dracut/commit/62be5b259d049ec1eeacc48687f0342ef8197056))
* **doc_site:**  remove reference to udev < 143 ([4cfac2cf](https://github.com/dracut-ng/dracut/commit/4cfac2cfaaebdda5587bc9aca4c711551aa44791))
* **dracut:**
  *  use grep -q/-s to silence output/error ([a80703e8](https://github.com/dracut-ng/dracut/commit/a80703e89cc65c184b6a04c8fa9a985e0ecea571))
  *  install items before dracut modules are included ([a2ebe31b](https://github.com/dracut-ng/dracut/commit/a2ebe31b18afe9d4746828965861e9ee11af5db1))
  *  add support for kernel name Image ([df933559](https://github.com/dracut-ng/dracut/commit/df933559cffbc85c4de2d008d3cb66b44fd16c68))
  *  enforce that hostonly is set for hostonly_install ([32b3b8c7](https://github.com/dracut-ng/dracut/commit/32b3b8c732c979f0e0842d99e473d4e6cae657a5))
  *  library directory creation in --kernel-only ([52155dde](https://github.com/dracut-ng/dracut/commit/52155dde883e315466c48142fc976905fa684d3d))
  *  use "-name" to avoid find matching temporary directory ([5c53a810](https://github.com/dracut-ng/dracut/commit/5c53a810bbc983efeaec17d88ac06a697059a201))
  *  decrease logging by default ([86cc122e](https://github.com/dracut-ng/dracut/commit/86cc122e916ea415eee0dc62368d585076a81627))
  *  do not call uname -r in chroot environments ([d4355425](https://github.com/dracut-ng/dracut/commit/d4355425b963e5fbd17912a227de92e23fb92be7))
  *  look for both vmlinuz and vmlinux for UKI creation ([686ab140](https://github.com/dracut-ng/dracut/commit/686ab1408b1cb9d955aebe661b54725e6a52e8c3))
* **dracut-init:**
  *  remove obsolete comment ([b1fab596](https://github.com/dracut-ng/dracut/commit/b1fab596cf5efb398e7e8cdd2b2b7d44a0d15aa7))
  *  remove the heuristic to determine fallback kernel version ([f9328b25](https://github.com/dracut-ng/dracut/commit/f9328b25ab2f443593d4c0f8a26bbd80fbf042a5))
* **dracut-install:**
  *  initialize the fts pointer ([60823653](https://github.com/dracut-ng/dracut/commit/60823653d0fdf1d33b0f80020cf55b06432eb134))
  *  cache resolve_deps calls for speed and less noise ([c3331ed4](https://github.com/dracut-ng/dracut/commit/c3331ed4f17d67c6b3ad8622c6900604d726e171))
  *  handling of multiple sonames in dlopen JSON ([23d32545](https://github.com/dracut-ng/dracut/commit/23d3254559db033041b262fa286ea5196f22f003))
  *  broken calls to mmap with 0 length ([063927bd](https://github.com/dracut-ng/dracut/commit/063927bd1d4263f4a32ca77b2fef2c51010611a7))
  *  the handling of absolute paths in sonames ([3484061b](https://github.com/dracut-ng/dracut/commit/3484061b922f360fa24a575474f88c9a735daf8c))
  *  the RUNPATH expansion returning empty strings ([950ebcbe](https://github.com/dracut-ng/dracut/commit/950ebcbe11a9cfb21f257e990761e52f8ce977f3))
  *  the -n short option for --dry-run ([3d4763ac](https://github.com/dracut-ng/dracut/commit/3d4763ac3feacb65ac9d7bf1c7c4805ef30f1b17))
* **dracut-rescue:**  add support for /run/initramfs/dracut.conf.d ([05692b89](https://github.com/dracut-ng/dracut/commit/05692b89bf29e3aa20292cc4d41902a7430b9659))
* **dracut-systemd:**
  *  install grep if initqueue is used ([ba6229e1](https://github.com/dracut-ng/dracut/commit/ba6229e1d3142c47ec2cbb9b0dd8860d0859dbc5))
  *  avoid matching extra root= substrings in cmdline ([4590c31a](https://github.com/dracut-ng/dracut/commit/4590c31ab9a9a378391d97c5ff7a9e3b9ff09458))
* **dracut-util:**  crash if CMDLINE ends with quotation mark ([4f6ca33d](https://github.com/dracut-ng/dracut/commit/4f6ca33d0e33240c32241d89a5999f15a9986913))
* **dracut.sh:**  check that custom fw search patch exists before reading it ([89dcdd91](https://github.com/dracut-ng/dracut/commit/89dcdd91bac6679cf88207d83ac698eccb3d2821))
* **dracut.sh,lsinitrd.sh:**  use obj{copy,dump} set by toolchain ([8d870e63](https://github.com/dracut-ng/dracut/commit/8d870e632bc5f82ae40c52e515ba3c4c6cce037d))
* **fedora:**  always include chroot binary ([aaed766b](https://github.com/dracut-ng/dracut/commit/aaed766b30d3dba70a4ecbda1272ce095189cb98))
* **fs-lib:**  include modules for charsets for working vfat support ([51bd1331](https://github.com/dracut-ng/dracut/commit/51bd13313a2c75e7443aad43fd3007af0b55fd34))
* **hwdb:**  make module-setup.sh executable ([118b3656](https://github.com/dracut-ng/dracut/commit/118b36564019c208694eac6b409a159d8bd34cfb))
* **iscsi:**
  *  only enable services if they are included ([63c48471](https://github.com/dracut-ng/dracut/commit/63c484710adbd2d4c8f1fd5546053d3c742f8f70))
  *  modify iscsid.service in initrd instead of host ([edd89c73](https://github.com/dracut-ng/dracut/commit/edd89c73dda6c6f7ff71163d458301ad69105dd9))
  *  drop ExecStartPre startup-checks.sh from iscsid.service ([b2287bb7](https://github.com/dracut-ng/dracut/commit/b2287bb7c4544d841b3d5b0510ce765753d990af))
  *  do not include /etc/iscsi/iscsid.conf in generic mode ([9b14963b](https://github.com/dracut-ng/dracut/commit/9b14963b0921c066969434489e72914647e8fdb4))
* **kernel-modules:**  add Cadence USB driver to base ([ff6a30c8](https://github.com/dracut-ng/dracut/commit/ff6a30c85eb0399d008b79133150adf62e1beb84))
* **kernel-modules-extra:**  remove stray \ before / ([614e9d34](https://github.com/dracut-ng/dracut/commit/614e9d34a69d7a8ef4ebb3ac5ceb77a13c968641))
* **livenet:**  source img-lib.sh for check_live_ram ([a9f52182](https://github.com/dracut-ng/dracut/commit/a9f52182800eeb0108790c0e4dbf89c4c23630a8))
* **lsinitrd:**
  *  drop --verbose from cpio --to-stdout call ([4a5b728b](https://github.com/dracut-ng/dracut/commit/4a5b728b6c9126c399be5aa1607cc234b8750c5e))
  *  use lowercase skip variable name ([8c3a6b6d](https://github.com/dracut-ng/dracut/commit/8c3a6b6d0b6c3ecc7de593595cdf91bada1ed8f2))
  *  avoid rechecking for squash images ([18af4e93](https://github.com/dracut-ng/dracut/commit/18af4e9318133cce21d11b53124c14306846e9a7))
* **man:**
  *  move the documentation hostonly and hostonly_mode variables ([bd0685ad](https://github.com/dracut-ng/dracut/commit/bd0685ad151494294feee76ff55da9b07d5b9a57))
  *  expand the documentation for hostonly-cmdline ([6a38b720](https://github.com/dracut-ng/dracut/commit/6a38b7205dd8eaf1b766cdce98e1456dc23b6a4b))
* **multipath:**  add udev rule 99-z-dm-mpath-late.rules ([de8b63f5](https://github.com/dracut-ng/dracut/commit/de8b63f563b845d308e87638c5bf45304f71dccf))
* **net-lib:**  always include af_packet ([e6f89767](https://github.com/dracut-ng/dracut/commit/e6f89767dabf9dfb34f4342d0bf217355024fe6b))
* **network:**  handle network selection properly ([8f076010](https://github.com/dracut-ng/dracut/commit/8f076010b237546b042238d4b025ad7404368533))
* **network-manager:**
  *  hostname not set with old systemd service units ([a33ae68d](https://github.com/dracut-ng/dracut/commit/a33ae68d86b1831bb758abc9e923aee24e1185a6), closes [#1743](https://github.com/dracut-ng/dracut/issues/1743))
  *  load required kernel modules ([584fb47c](https://github.com/dracut-ng/dracut/commit/584fb47cbc0e45837c0c6a9e8606591707789ba6))
* **nvmf:**  do not install hostonly configuration in generic initramfs ([8b816ea9](https://github.com/dracut-ng/dracut/commit/8b816ea9ac184e83227f26c3da22724550661443))
* **overlayfs:**  overlayfs should not use rootfsflags as mount options ([deeb670c](https://github.com/dracut-ng/dracut/commit/deeb670c28d12a478bbea95e29677e436d1912fb))
* **plymouth:**
  *  do not install plymouth-set-default-theme into initrd ([1120dbc5](https://github.com/dracut-ng/dracut/commit/1120dbc5113d338efc844ebd35e04c1f5d3e9b2e))
  *  check all library directories for Plymouth ([1ac7e21e](https://github.com/dracut-ng/dracut/commit/1ac7e21ef679aefc2aa6a9b90257c2ed0ceaba9e))
  *  drop depending on bash ([deb3717b](https://github.com/dracut-ng/dracut/commit/deb3717bdc1677e80807a57ef5e5c6daf224e888))
* **release:**  force push (for updating) ([d71b6f51](https://github.com/dracut-ng/dracut/commit/d71b6f51ad33748e5143317c36db4f920018fc4b))
* **resume:**  avoid matching extra resume= substrings in cmdline ([a58b30e2](https://github.com/dracut-ng/dracut/commit/a58b30e2314f247515df901828175d0f0c1e8595))
* **systemd:**
  *  make dbus optional dependency ([fdfa8998](https://github.com/dracut-ng/dracut/commit/fdfa899895d53d5aa1a6821e308743d38f5c6456))
  *  add compatibility with systemd v258 ([eeef28a5](https://github.com/dracut-ng/dracut/commit/eeef28a5efadfb7e502936cef3f1167f08ec6e66))
* **systemd-networkd:**  correct path of 99-default.network on hostonly=no ([523c9b05](https://github.com/dracut-ng/dracut/commit/523c9b05aef1fa57d0623511137572287a76769d))
* **systemd-portabled, initqueue:**  enable systemd type units ([51a0e49f](https://github.com/dracut-ng/dracut/commit/51a0e49fdffcd94a49079b80a33389d10f698a8f))
* **systemd-sysext:**
  *  stop adding *.raw to the initramfs automatically ([f7f7e856](https://github.com/dracut-ng/dracut/commit/f7f7e856918ffe09b302fd817f2324bb5b6a83ac))
  *  skip manual systemct enablement for systemd>=258 ([73ad42fa](https://github.com/dracut-ng/dracut/commit/73ad42fa0c3407edb9a48a3bd1021b37a022d96f))
  *  package initrd.target.wants symlinks ([74e04b63](https://github.com/dracut-ng/dracut/commit/74e04b63f8620fbe258e5b27047b21844a4db2c7))
* **systemd-sysusers:**
  *  spelling of after ([d361c3f0](https://github.com/dracut-ng/dracut/commit/d361c3f0cfca6ce65e648934447e0ae355b6e06b))
  *  increase ordering from 68 to 78 ([80bc6ba1](https://github.com/dracut-ng/dracut/commit/80bc6ba180407b3ddd6e141d7567fe8fb15f1939))
* **test:**  make sure $1 is not read as an unbound variable ([fbbd7d5f](https://github.com/dracut-ng/dracut/commit/fbbd7d5f9378390b6d00aea8242d23a0924d2e0f))
* **test-functions:**  use absolute path ([088bef78](https://github.com/dracut-ng/dracut/commit/088bef78181677d7052e0042bbaf1e7616ab90e4))
* **test-makeroot:**  make it dependent on initqueue ([e588aeaf](https://github.com/dracut-ng/dracut/commit/e588aeaf9b61edf71dd00cca8ad6c4162619275f))
* **ubuntu:**  set DISTRIBUTION when building container ([211a1e7a](https://github.com/dracut-ng/dracut/commit/211a1e7acbf78e27107325fa45f3fba938051ce0))
* **virtfs, virtiofs:**  dracut module should not delete rootfs files ([54c0f12f](https://github.com/dracut-ng/dracut/commit/54c0f12f1d65d346e2fe7be19fc6316e8da7358e))

#### Contributors

- Jo Zzsi <jozzsicsataban@gmail.com>
- Benjamin Drung <benjamin.drung@canonical.com>
- James Le Cuirot <jlecuirot@microsoft.com>
- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- Daniel Hast <hast.daniel@protonmail.com>
- Martin Wilck <mwilck@suse.de>
- Pavel Valena <pvalena@redhat.com>
- Vitaly Kuznetsov <vkuznets@redhat.com>
- dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
- Alexander Zubkov <green@qrator.net>
- David Disseldorp <ddiss@suse.de>
- Tomas Bzatek <tbzatek@redhat.com>
- Benjamin <benjamin@cybercorp.fr>
- Coiby Xu <coxu@redhat.com>
- Deli Zhang <deli.zhang@cloud.com>
- Fabian Vogt <fvogt@suse.de>
- Flos Lonicerae <lonicerae@gmail.com>
- Frantisek Sumsal <frantisek@sumsal.cz>
- Koen Kooi <koen.kooi@oss.qualcomm.com>
- Nowa Ammerlaan <nowa@gentoo.org>
- turret <turret@duck.com>

dracut-108
=============

#### Performance

* **systemd-udevd:**  99-systemd.rules added in two places ([a8c0a15c](https://github.com/dracut-ng/dracut/commit/a8c0a15cf9b61b7f606e4162164b526eb58f620b))
* **watchdog:**  only install wdctl for the non-systemd case ([ad0fd3a8](https://github.com/dracut-ng/dracut/commit/ad0fd3a8dfcb155290bc8b7ec9f83144daa3d9df))

#### Features

*   add Debian/Ubuntu specific Dracut configuration ([cba1a2c2](https://github.com/dracut-ng/dracut/commit/cba1a2c2cda9d2fb26fb694f59dac88bf1b0b725))
*   allow the use of $kernel in initrdname= config ([696397dd](https://github.com/dracut-ng/dracut/commit/696397dd8d8b200549fba4b564f97b1864143093))
*   add support for removing a space separated list of files ([f8dfe3ee](https://github.com/dracut-ng/dracut/commit/f8dfe3ee5b958262c38a821b15443893e400dba0))
*   make variable set check work with "set -u" ([ee8f4f9d](https://github.com/dracut-ng/dracut/commit/ee8f4f9d3e011c829bda7a8b7ee19aef85dd6ffb))
*   support dracutsysrootdir being unset ([348888b8](https://github.com/dracut-ng/dracut/commit/348888b8d9067a9e983650129b7a3ea64fb8430f))
*   tests are not packaged by default to simplify packaging ([e65a87cf](https://github.com/dracut-ng/dracut/commit/e65a87cf0a14a5c7157ea4cfe56eb8639435eaa4))
*   set hostonly_cmdline config to no by default ([efaee447](https://github.com/dracut-ng/dracut/commit/efaee4473680db78f4f3244ba952e783ea3b5aa9))
*   set hostonly config by default in configure ([62fdf59c](https://github.com/dracut-ng/dracut/commit/62fdf59c94ef7ec2261d054384ceddff39c3643b))
* **Makefile:**  explicitly list configs to install ([f7416501](https://github.com/dracut-ng/dracut/commit/f7416501a7465318682bf7c619c1f52bdb6b1b02))
* **base:**  add support for rd.driver.pre ([5ca76df3](https://github.com/dracut-ng/dracut/commit/5ca76df3a29467404611443d75539a02824a0dfa))
* **crypt-gpg:**  handle multiple gpg pubkeys ([28ad7910](https://github.com/dracut-ng/dracut/commit/28ad79106c7fc87ba7f5f6f0c86faeb4191c567e))
* **dracut:**
  *  drop DRACUT_PATH and rely on PATH ([2606f985](https://github.com/dracut-ng/dracut/commit/2606f985d6f38c464a8485421683571e2df266dd))
  *  support SOURCE_DATE_EPOCH ([dfcfa6fb](https://github.com/dracut-ng/dracut/commit/dfcfa6fbe8007e62f4f7977f69646710f0af6100))
  *  allow users to choose which dlopen dependencies they want ([96a91d04](https://github.com/dracut-ng/dracut/commit/96a91d04ddf004071007870dc1cabab6b4c94f69))
  *  replace ldd with dracut-install --dry-run or header check ([e8b733f7](https://github.com/dracut-ng/dracut/commit/e8b733f7c545b35511711ae6514065dce6530724))
  *  set systemdversion global var using pkg-config ([ed80f9f4](https://github.com/dracut-ng/dracut/commit/ed80f9f42c2e92c9494ddaad9cfca0312319eec2))
* **dracut-install:**
  *  add --dry-run option to replace external ldd usage ([161153f9](https://github.com/dracut-ng/dracut/commit/161153f901877f825f3e038367fee631eacac8f2))
  *  extend new ELF parsing code to replace ldd calls ([aac5c914](https://github.com/dracut-ng/dracut/commit/aac5c914af84e8880fcc154ebb93a05c6b6855dc))
  *  parse ELF .note.dlopen entries for extra deps ([19b5faad](https://github.com/dracut-ng/dracut/commit/19b5faad97971a6d906740de28cfe366a7fae687))
* **initqueue:**  factor out initqueue into its own module ([3daf6783](https://github.com/dracut-ng/dracut/commit/3daf67830d8db3b12bc45eef9f8f29f606192db9))
* **network-manager:**  use upstream initrd services if available ([83dffc58](https://github.com/dracut-ng/dracut/commit/83dffc58f606ad7ad47a32716ce240831d7f018f))
* **resume:**  do not depend on initqueue if systemd is used ([34457e07](https://github.com/dracut-ng/dracut/commit/34457e070bc9d5c5bc622363eb7acf4767f16e46))
* **rootfs-block-fallback:**  factor out rootfallback into its own module ([2676f1a5](https://github.com/dracut-ng/dracut/commit/2676f1a5fc9a090866d0b29bf161850a7e93e87e))
* **watchdog:**  do not depend on initqueue if systemd is used ([c8dbd9ec](https://github.com/dracut-ng/dracut/commit/c8dbd9ecc8ea1983c6e51c1205939247a434c661))

#### Bug Fixes

*   load essential storage kernel modules in sloppy hostonly mode ([87304767](https://github.com/dracut-ng/dracut/commit/87304767b16f45b7eacd1e5e622adab029e7902e))
*   increase deteminism by not relying on the default sorting from ls ([c9f6b867](https://github.com/dracut-ng/dracut/commit/c9f6b8674e38b19c7666e30601bb5ed6a205b661))
*   network-manager dracut module no longer depends on systemd ([8f063e23](https://github.com/dracut-ng/dracut/commit/8f063e23370e8953b6189990a1179517d2454c69))
*   support DRACUT_SYSTEMD being unset ([79ffbd28](https://github.com/dracut-ng/dracut/commit/79ffbd28294818a36e515a441142125d70e3acbb))
*   support hostonly being unset ([c85c9324](https://github.com/dracut-ng/dracut/commit/c85c93245bf48d1a47e12c30cdb4aa49ea2a585e))
*   support DRACUT_RESOLVE_LAZY being unset ([3d383ba4](https://github.com/dracut-ng/dracut/commit/3d383ba4fa98993a423c849054cb1d51eff81b24))
*   loongarch architecture support ([38f44b35](https://github.com/dracut-ng/dracut/commit/38f44b35d05587c601caea50d765b89be6f9305d))
*   let check_vol_slaves_all return 1 when checks on all slaves fail ([b117013b](https://github.com/dracut-ng/dracut/commit/b117013b7829883f6b2b1d0fe12e8a7772a38029))
*   improve hostonly sloppy mode ([53537ae7](https://github.com/dracut-ng/dracut/commit/53537ae77e49ab5ba157fdab544489db10ad8b1b), closes [#1321](https://github.com/dracut-ng/dracut/issues/1321))
*   load more kernel modules in sloppy hostonly mode ([de862885](https://github.com/dracut-ng/dracut/commit/de862885ec55bb19bfa3e3f1afd27577b7c5e309))
* **Makefile:**  remove test modules after renumbering ([80961ee0](https://github.com/dracut-ng/dracut/commit/80961ee0b36ca3ff60cacd68986217506c305176))
* **base:**
  *  base module failure if root password is already set ([e4551d40](https://github.com/dracut-ng/dracut/commit/e4551d403f9fd6e09bde401c16bb0974bce3a23a))
  *  dracut-lib.sh soft depends on poweroff/reboot/halt ([237108c3](https://github.com/dracut-ng/dracut/commit/237108c332a4a738c29e9b5210cdd00b7922c6ce))
  *  support PREFIX being unset ([7bea9dfe](https://github.com/dracut-ng/dracut/commit/7bea9dfed63207b1fb7b9fd5b5aab4b038727652))
  *  only create nobody user for nfs dracut module ([8934a8e5](https://github.com/dracut-ng/dracut/commit/8934a8e50fc89f7f13539be027149b1246c2481d))
* **dmsquash-live:**  erofs collision with latest util-linux ([950475e8](https://github.com/dracut-ng/dracut/commit/950475e848c9eec03b5283bfd1d8722c051edd2d))
* **dracut:**
  *  only call uname -r if it is safe to do ([3f4497ed](https://github.com/dracut-ng/dracut/commit/3f4497ed842ba8be998893b441cc936e2721cd63))
  *  detect if systemd-detect-virt is available before calling it ([5d3298ea](https://github.com/dracut-ng/dracut/commit/5d3298ea9ed8790e57514d1d0ea2117fb7af363b))
  *  consolidate reporting running in a container ([000f5dbf](https://github.com/dracut-ng/dracut/commit/000f5dbfb6539d03fc90165d04de88b49ff6bedb))
  *  ensure hardlink deduplication is reproducible ([9fdf683f](https://github.com/dracut-ng/dracut/commit/9fdf683f6d2f7c6ecbd98884f142de86bbea5a56))
  *  respect PKG_CONFIG env var instead of hardcoding pkg-config ([0ee92dbb](https://github.com/dracut-ng/dracut/commit/0ee92dbba684e2c39b615a50b03ae5d15e3dc18e))
* **dracut-init:**  use sysroot when checking udev rule program existence ([c1000cda](https://github.com/dracut-ng/dracut/commit/c1000cda35959b6f7dfb2e88cc657a846e44d841))
* **dracut-init.sh:**
  *  support DRACUT_NO_XATTR being unset ([d520252a](https://github.com/dracut-ng/dracut/commit/d520252aae1553ecc4d368236287baf3a32040c9))
  *  initialize _files in inst_libdir_file ([2311abeb](https://github.com/dracut-ng/dracut/commit/2311abeba53ec353f494240d7da9b24aad9e3d5e))
* **dracut-initramfs-restore:**  check for Debian initrd.img symlink ([f80128e9](https://github.com/dracut-ng/dracut/commit/f80128e91aae68449e1006cc7a9d6fcf8eacea32))
* **dracut-install:**
  *  sort output of --modalias ([41e43068](https://github.com/dracut-ng/dracut/commit/41e4306840959b88758aad6a768c613b0864c763))
  *  install all suppliers of a supplier's module ([80574db7](https://github.com/dracut-ng/dracut/commit/80574db78cf7d0cf007d933cf950ac159f6de3b3))
  *  do not limit supplier handling to platform bus ([e35c5173](https://github.com/dracut-ng/dracut/commit/e35c517310d7e5edb24c10bf5be7f597502197a2))
  *  add sysfs node parents' modules as dependencies ([3607cd8f](https://github.com/dracut-ng/dracut/commit/3607cd8fcbe433802e70d7cc055b18f829cb3b3c))
  *  rework broken destination existence logic ([425e263b](https://github.com/dracut-ng/dracut/commit/425e263be559c7a005579072f4051c047a1c1511))
  *  plug memory leak on kerneldir ([082b6b0a](https://github.com/dracut-ng/dracut/commit/082b6b0a6e544865948f177126aac7d40c69b1ba))
  *  deadcode.DeadStores static analyzer warnings ([28041543](https://github.com/dracut-ng/dracut/commit/28041543f661a918ce1eb97ce0b69b20cb891c9b))
* **dracut-lib.sh:**  initialize variables in getargs ([ef60bd71](https://github.com/dracut-ng/dracut/commit/ef60bd7179505b49ef4c9fd077d7647e0161af2b))
* **dracut-logger.sh:**  initialize errmsg in dlog_init ([f35a8c7f](https://github.com/dracut-ng/dracut/commit/f35a8c7f04c02cea063a8c0346c9993f120a8196))
* **dracut.conf.d:**  reserve namespace 50 to out-of-tree configurations ([d470b436](https://github.com/dracut-ng/dracut/commit/d470b436aecceacd520d1629484e7365c9607183))
* **dracut.sh:**
  *  do not use uname to detect kernel version in a container ([2b2debd7](https://github.com/dracut-ng/dracut/commit/2b2debd7947b7d5a357c1a89691a75dfd3565747))
  *  initialize variables that get exported ([50426818](https://github.com/dracut-ng/dracut/commit/504268187b863d11a8c39e0a242aa77e688c8b0d))
  *  don't pass empty string as dir ([758f3eaf](https://github.com/dracut-ng/dracut/commit/758f3eaf61ac210507715f4b5681e24f6dc4d3b0), closes [#1275](https://github.com/dracut-ng/dracut/issues/1275))
* **fcoe-uefi:**  exit early on empty vlan ([555b6e1d](https://github.com/dracut-ng/dracut/commit/555b6e1d685ce5960109aefe736ed3ebdf50a839))
* **fips:**  make sha512hmac an optional requirement ([3d319b55](https://github.com/dracut-ng/dracut/commit/3d319b55a65d9be2c9a9dade3c23cd0f377416b7))
* **generic.conf:**  increase ordering for generic.conf ([d823fd86](https://github.com/dracut-ng/dracut/commit/d823fd86d364dce3b26cd0cc441aa4c86a8db20c))
* **i18n:**  add $dracutsysrootdir to systemd-vconsole-setup.service path ([90956522](https://github.com/dracut-ng/dracut/commit/90956522ba143125de9f060368cef83aa64e1a3e))
* **livenet:**  drop stray command call ([9135136d](https://github.com/dracut-ng/dracut/commit/9135136d7dfca0deb8b0c618c43e3ffcc35b3090), closes [#1240](https://github.com/dracut-ng/dracut/issues/1240))
* **lsinitrd:**  resolve initrd to real path ([22d93bc0](https://github.com/dracut-ng/dracut/commit/22d93bc0cd5afd0d9170c6bdc8ba7ceac68b8eb5))
* **man:**  document what to expect running dracut non-root ([b853eba8](https://github.com/dracut-ng/dracut/commit/b853eba87684d608637493f8c8214dda4ec96102))
* **modules:**
  *  free up range 00-09 to out of tree dracut modules ([1edcb076](https://github.com/dracut-ng/dracut/commit/1edcb07619958f05727d3c30b72f7810b62c22a1))
  *  document known module dependencies ([2d98ddb5](https://github.com/dracut-ng/dracut/commit/2d98ddb5d273348db32c248561560dc0975a0189))
  *  move more modules with unimportant ordering to 70 ([c439438d](https://github.com/dracut-ng/dracut/commit/c439438d4f87f391db021b6037830a034f321dfd))
  *  all modules with 99 ordering should have a unique number ([2199846f](https://github.com/dracut-ng/dracut/commit/2199846ffebca406a957b781509c42a42d101ba7))
* **network-manager:**  depend on dbus only when using systemd ([58baf861](https://github.com/dracut-ng/dracut/commit/58baf861c68b1f233da4c89d1a8a398ac307cb6c))
* **simpledrm:**  add =drivers/gpu/drm/panel ([b7a2f8d0](https://github.com/dracut-ng/dracut/commit/b7a2f8d0bdcc57ef7ad137fde657c4a359b7a824))
* **systemd:**
  *  systemd.volatile needs overlayfs kernel module ([e1452003](https://github.com/dracut-ng/dracut/commit/e14520035286dbb4ee856cac2e05c1f21c6e148d))
  *  make checking for systemd availability consistent ([8e575556](https://github.com/dracut-ng/dracut/commit/8e575556da2bc6d41265fdffd4c4bf7bd69ab71e))
* **systemd-cryptsetup:**  don't pull in fido2/pkcs11/tpm2-tss if omitted ([01b369a5](https://github.com/dracut-ng/dracut/commit/01b369a5866853c8dc5c53c7d4d8613e5721be34))
* **systemd-repart:**
  *  allow partition format ([02201361](https://github.com/dracut-ng/dracut/commit/02201361ac0e646f9367ec7f14b215795e89cf6a))
  *  copy systemd system drop-in configuration ([bb8bf124](https://github.com/dracut-ng/dracut/commit/bb8bf124526f25ac698ef05bc95eb2fe625d69c7))
* **systemd-sysext:**
  *  install the required kernel modules ([7f524d3d](https://github.com/dracut-ng/dracut/commit/7f524d3d24528a7261f0cce1e445ef464f5bf126))
  *  make non-hostonly non-host ([e42755c3](https://github.com/dracut-ng/dracut/commit/e42755c342bdc15ae77be722f0ec2a8c23390be5))
* **systemd-sysusers:**
  *  maintain users and groups ([50285645](https://github.com/dracut-ng/dracut/commit/50285645e617a537e69d4eb8f22dbe83c9b22665))
  *  remove (g)shadow created by systemd-sysusers ([97b5f91f](https://github.com/dracut-ng/dracut/commit/97b5f91ff043b13b213438295675ff85e83dc6de), closes [#1242](https://github.com/dracut-ng/dracut/issues/1242))
* **systemd-udevd:**  handle root=gpt-auto for systemd-v258 ([fa17b6fb](https://github.com/dracut-ng/dracut/commit/fa17b6fb0e5a226a83588c2d8fdec5ff285f5eab))
* **test:**  renumber test modules to 70 ([99ed458b](https://github.com/dracut-ng/dracut/commit/99ed458b5b1870c57e936a216149c9b7bb5b9f21))

#### Contributors

- Jo Zzsi <jozzsicsataban@gmail.com>
- Benjamin Drung <benjamin.drung@canonical.com>
- James Le Cuirot <jlecuirot@microsoft.com>
- Marcos Mello <marcosfrm@gmail.com>
- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- Alper Nebi Yasak <alpernebiyasak@gmail.com>
- Chris Riches <chris.riches@nutanix.com>
- David Tardon <dtardon@redhat.com>
- farfalleflickan <6597735+farfalleflickan@users.noreply.github.com>
- Adam Williamson <awilliam@redhat.com>
- Andrew Gunnerson <accounts+github@chiller3.com>
- Coiby Xu <coxu@redhat.com>
- Emanuele Giuseppe Esposito <eesposit@redhat.com>
- Ian Wienand <iwienand@redhat.com>
- Karel Zak <kzak@redhat.com>
- Marc Herbert <marc.herbert@intel.com>
- Pavel Valena <pvalena@redhat.com>
- Vitaly Kuznetsov <vkuznets@redhat.com>
- dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
- zhuyaliang <15132211195@163.com>

dracut-107
=============

This release marks the one-year anniversary of this project.

To celebrate the anniversary, the project would like to thank the following Linux distributions that rely on this project for initramfs generation.
* Adélie Linux
* ALT Linux
* AOSC
* Azure Linux
* Debian (dracut-install)
* Chimera Linux (dracut-install)
* CRUX
* EndeavourOS (Arch based)
* Fedora and Red Hat Enterprise Linux
* GardenLinux (Debian based)
* Gentoo
* KaOS
* Lubuntu (Ubuntu based)
* OpenMamba
* OpenMandriva
* Side Linux
* Solus
* Ubuntu (dracut-install)
* Void Linux

The following independent distributions have packaged releases of this project, enabling dracut as an alternative initramfs generator:
* Alpine
* Arch
* Slackware

#### Bug Fixes

*   improve hostonly sloppy mode ([8519dcdb](https://github.com/dracut-ng/dracut/commit/8519dcdb154b55c5feb6e4638a525c33e8fa7f66))
*   don't use command -v to find binaries in the sysroot ([c0d3b120](https://github.com/dracut-ng/dracut/commit/c0d3b12024b9e17d3d602b82e8ede82e1aa3de80))
*   add $dracutsysrootdir to paths where it should be present ([a3fea596](https://github.com/dracut-ng/dracut/commit/a3fea5968b4c130a38057a3b87643acc13d5c55b))
* **90kernel-modules:**  explicitly include xhci-pci-renesas ([20cc20d2](https://github.com/dracut-ng/dracut/commit/20cc20d2ac9c2908da6735b04dba49c1cb1b0bab))
* **base:**
  *  tighten /dev/pts permissions ([5ec66e97](https://github.com/dracut-ng/dracut/commit/5ec66e97e6e3e09ecc1d43132c1c6496982ffc52))
  *  only set ID to dracut if systemd is not used ([82487fc8](https://github.com/dracut-ng/dracut/commit/82487fc81d29dd7509e377028ec20c64a271de7f))
* **crypt:**  always install s390 crypto modules ([dea50f64](https://github.com/dracut-ng/dracut/commit/dea50f649c8c9317ef1c4f03bb9e02eae5c07459))
* **dracut:**
  *  kernel module name normalization in drivers lists ([8674d84f](https://github.com/dracut-ng/dracut/commit/8674d84f9be04aa16ca3ed3dfe05b5e066bf7959))
  *  protect existing output file against build errors ([39a765de](https://github.com/dracut-ng/dracut/commit/39a765debe212407cce28e6d3a84a65e4efc1c6e))
  *  avoid mktemp collisions with find filter ([9b822c31](https://github.com/dracut-ng/dracut/commit/9b822c31e3c096a276904c0d6ebfd379ec443e23))
* **dracut-init:**
  *  do not detect virt environment in non-hostonly mode ([b2c72e10](https://github.com/dracut-ng/dracut/commit/b2c72e100db036e5eaaa2522b6d51351ac9834f9))
  *  assign real path to srcmods ([bb6d0c11](https://github.com/dracut-ng/dracut/commit/bb6d0c11d321cb71817bbc3f1dcd7bdcef8a8409))
* **dracut-install:**  install compressed blobs that match wildcard fwpath ([57911e76](https://github.com/dracut-ng/dracut/commit/57911e76e2826fa6d9f2b80915cf99c6eb0e05b0))
* **dracut-lib:**  support "set -e" in setdebug ([89da4257](https://github.com/dracut-ng/dracut/commit/89da4257a6ffa737a69f7095bb41d5ae3f247d82))
* **hwdb:**  enable hwdb dracut module when hostonly is sloppy ([5ff7dab0](https://github.com/dracut-ng/dracut/commit/5ff7dab00830c25168eff1f962685ab915d3c18b))
* **iscsi:**
  *  make sure services are shut down when switching root ([fcde3355](https://github.com/dracut-ng/dracut/commit/fcde3355456323be9674aac1d00e3c66683b7f99))
  *  don't require network setup for qedi ([3d5bab81](https://github.com/dracut-ng/dracut/commit/3d5bab815570d2a271a45ceb9135f7cb3bde11f1))
* **man:**  --include can be specified multiple times ([18375a5c](https://github.com/dracut-ng/dracut/commit/18375a5c3851c67ef8050e527c57cb3a2b41b112))
* **mdraid:**  do not call mdadm with full path ([b0c37531](https://github.com/dracut-ng/dracut/commit/b0c37531092d3ccd20a1a867975b67c44aa8a5f9))
* **multipath:**
  *  disable user_friendly_names with mpathconf ([1d7464cf](https://github.com/dracut-ng/dracut/commit/1d7464cf2ee2d99f0eec545c4d3d84925df3e76f))
  *  skip default multipath.conf with mpathconf ([c43b7905](https://github.com/dracut-ng/dracut/commit/c43b79056ffdb7b410e70550a8ad8d137b4720c0))
* **nfs:**
  *  add possible `statd` user and group ([7eaa8536](https://github.com/dracut-ng/dracut/commit/7eaa8536fae73aa65fae604820f10e842a18bc88))
  *  use `DRACUT_CP` instead of `cp` ([2f5a759f](https://github.com/dracut-ng/dracut/commit/2f5a759f490bb813ec24a685f015b15ff196783b))
  *  libnfsidmap plugins not added in some distributions ([6b30662e](https://github.com/dracut-ng/dracut/commit/6b30662e6e4720428f0efb0ab85c80303dd34afd))
* **release:**  tagging and release generation is no longer automated ([5c2864dc](https://github.com/dracut-ng/dracut/commit/5c2864dc41c84f911132f0bba9cb50dbd35e27e1))
* **rngd:**
  *  adjust license to match the license of the whole project ([da099c30](https://github.com/dracut-ng/dracut/commit/da099c30177c6a88e96f14fde3f07bd6cfc0dabf))
  *  do not check for +x perms ([04841c42](https://github.com/dracut-ng/dracut/commit/04841c426376ca6ca41f47a97a638a72644a7456))
* **squash-erofs:**  adjust configuration in order to match SquashFS ([e2f19b65](https://github.com/dracut-ng/dracut/commit/e2f19b650391dc5565e1391745433c4ee16726b1))
* **systemd-sysusers:**
  *  make sure tss user for tpm2 is created ([c6d38cb4](https://github.com/dracut-ng/dracut/commit/c6d38cb479f7f630ec13e5f7975460e746495d81))
  *  silence "Creating " on stderr ([cb8fb964](https://github.com/dracut-ng/dracut/commit/cb8fb9641feec8ee3e0ce249da98becc6cdbb98b))
  *  always silence stdout ([62c75393](https://github.com/dracut-ng/dracut/commit/62c75393ea18b65ba0f7f224070c3bb94d3bd930))
* **systemd-veritysetup:**  install dm-verity kernel module ([f3fffa1e](https://github.com/dracut-ng/dracut/commit/f3fffa1edce2fd5e542c115296c9b0856611faa7))

#### Features

*   strip out unused/unlikely AMDGPU firmware ([c06f2481](https://github.com/dracut-ng/dracut/commit/c06f24818b7fbbf32a7f37fb725c1f2e58f13cc0))
*   add simpledrm module (as subset of drm module) ([2ae73d63](https://github.com/dracut-ng/dracut/commit/2ae73d639834758a88b34033693bd97a7b1ed2f0))
* **UKI:**  use ukify when available to generate UKI ([acfddd69](https://github.com/dracut-ng/dracut/commit/acfddd69f0575fba29b19e64873f4e0bbecc17f5))
* **btrfs:**  also install btrfstune ([ddbeed81](https://github.com/dracut-ng/dracut/commit/ddbeed81b2d43a03a16dc60ff76fd0355d4be5b9))
* **systemd:**  add new systemd-validatefs@.service ([1b5669c1](https://github.com/dracut-ng/dracut/commit/1b5669c1d89e0cc1134ad5b0aa5c091144d24b84))
* **systemd-integritysetup:**  add remote-integritysetup.target ([4402aeb2](https://github.com/dracut-ng/dracut/commit/4402aeb271933e6b542f5d9a4ff13f6e8b97e6c2))

#### Performance

* **base:**  move the chmod dependency from base to systemd ([ddc1f54d](https://github.com/dracut-ng/dracut/commit/ddc1f54d3ec96c55c444af22a0a964cb48266a21))

#### Contributors

- Jo Zzsi <jozzsicsataban@gmail.com>
- Benjamin Drung <benjamin.drung@canonical.com>
- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- James Le Cuirot <jlecuirot@microsoft.com>
- Benjamin Marzinski <bmarzins@redhat.com>
- Martin Wilck <mwilck@suse.de>
- Alexander Tsoy <alexander@tsoy.me>
- Brian Fjeldstad <bfjelds@microsoft.com>
- Dylan Aïssi <dylan.aissi@collabora.com>
- Gao Xiang <hsiangkao@linux.alibaba.com>
- Laszlo Gombos <laszlo.gombos@gmail.com>
- Mark Harmstone <mark@harmstone.com>
- Mingcong Bai <jeffbai@aosc.io>
- Nowa Ammerlaan <nowa@gentoo.org>
- Stefan Dirsch <sndirsch@suse.de>
- Thien Trung Vuong <tvuong@microsoft.com>
- Xinhui Yang <cyan@cyano.uk>
- You-Sheng Yang <vicamo.yang@canonical.com>

dracut-106
=============

#### Bug Fixes

*   check if xx-lib.sh is needed before executing ([8b71a80e](https://github.com/dracut-ng/dracut/commit/8b71a80edfca725e8aa281a4f91c55ff6234cc82))
*   check if dracut-lib.sh is needed before executing ([8f249c2b](https://github.com/dracut-ng/dracut/commit/8f249c2b3ed37f2fbd356c12e71a8b27ff2d87a5))
*   add bash dependency when bash scripts are used in the module ([3a04a139](https://github.com/dracut-ng/dracut/commit/3a04a139700ffc7fe7a4897bb6067ebc46972874))
*   initqueue -> /sbin/initqueue ([6f9b5a52](https://github.com/dracut-ng/dracut/commit/6f9b5a52307011cec016b06c2caf96c2788a52eb))
*   set initrd-release in the base module ([41f9e8f9](https://github.com/dracut-ng/dracut/commit/41f9e8f9acde08ab5ebf9f33cff627f3192bb8b9))
*   remove extra bracket ([512215c7](https://github.com/dracut-ng/dracut/commit/512215c79ef433cf5e29daa64ca3632c7532e091))
* **01fips-crypto-policies:**  use /bin in shebang ([f7ca0f3e](https://github.com/dracut-ng/dracut/commit/f7ca0f3ef3c7635cee334ad7d5a82b74b989c44c))
* **35network-manager:**
  *  install nftables kernel modules needed ([fca71490](https://github.com/dracut-ng/dracut/commit/fca714903c634ad5d1a90b425bc4231aa5e358e2))
  *  install nft binary during module installation ([a6264d17](https://github.com/dracut-ng/dracut/commit/a6264d1726d9a89ecb8b45c6215768755dcb8ba7))
* **ENC-RAID-LVM:**  correct test name and remove obsolete step ([90f46fcb](https://github.com/dracut-ng/dracut/commit/90f46fcbab236a603c5554c75416db5d1199cee9))
* **Makefile:**
  *  remove irrelevant testcases ([5b58bbea](https://github.com/dracut-ng/dracut/commit/5b58bbead35fb5d09c44f9e98219bf7b9ed93ff5))
  *  path for make clean ([a81782ce](https://github.com/dracut-ng/dracut/commit/a81782ce44a46cf9880a1da42c70bfad15ce8cb4))
* **base:**
  *  fallback when shell-interpreter is not included ([7f13ea21](https://github.com/dracut-ng/dracut/commit/7f13ea21834f0e080675d6750af4d866b84e5c9f))
  *  remove fallback for shell selection ([e139edb8](https://github.com/dracut-ng/dracut/commit/e139edb87cf8d5a6199bf53d78f16664fb27155f))
* **crypt:**  crypt-lib.sh optionally depends on stty ([4532fb0f](https://github.com/dracut-ng/dracut/commit/4532fb0f420a28026b91abda2ca0cc2e69aecca2))
* **dm:**  remove 59-persistent-storage-dm.rules ([d2ade8a6](https://github.com/dracut-ng/dracut/commit/d2ade8a6bf084c4cfb104dc9eff9917ea9bb9110))
* **dmsquash-live-root.sh:**  support images with non-existing /proc ([e37c67f6](https://github.com/dracut-ng/dracut/commit/e37c67f6f573ca5a15e88e5899e92ce1a8582bac))
* **docs:**  correct spelling mistake of recommended ([4e03ac7c](https://github.com/dracut-ng/dracut/commit/4e03ac7cdc41bb8d26a4e44d4202564fde704dee))
* **dracut:**  rework timeout for devices added via --mount and --add-device ([c79fc8fd](https://github.com/dracut-ng/dracut/commit/c79fc8fd0d4b9aaa8e753296cbafdb1f82781d08))
* **dracut-functions.sh:**
  *  check_kernel_module go one dir further up ([16abd45f](https://github.com/dracut-ng/dracut/commit/16abd45f8227841697d2d8b1e5ab1a8237ad38df))
  *  check for modules in --kmoddir, not in --sysroot ([b90eda4b](https://github.com/dracut-ng/dracut/commit/b90eda4b431af23d1101f1ea68b656929c6a82b2))
* **dracut-init:**  add compatibility with Debian/Ubuntu for libdirs detection ([8809b246](https://github.com/dracut-ng/dracut/commit/8809b2468aa2e3fd2ce4ff99f1cc4d400a190cf2))
* **dracut-lib:**  initialize getcmdline/getarg local variables ([fc18d0b3](https://github.com/dracut-ng/dracut/commit/fc18d0b317f463dc16351104ba260a08955694ff))
* **dracut-systemd:**
  *  check SYSTEMD_SULOGIN_FORCE before allowing passwordless ([27024d67](https://github.com/dracut-ng/dracut/commit/27024d67f96b5ee0ad7260e3c6796375a56467e5))
  *  check systemd-cryptsetup before including ([484a8a23](https://github.com/dracut-ng/dracut/commit/484a8a23f11146f3360622b91f453f33e5fff0c2))
  *  unquote variable in udev conf ([3b753bf7](https://github.com/dracut-ng/dracut/commit/3b753bf7b7d6cf69f8ece5d6e591e66c1cbaa791))
* **dracut.sh:**
  *  do not add cmdline for force_drivers if --kernel-only ([95fe9048](https://github.com/dracut-ng/dracut/commit/95fe904812ff4f192e56cf498983e3264c8135b4))
  *  ensure abs path for objcopy args ([1579bb0c](https://github.com/dracut-ng/dracut/commit/1579bb0c77d9e1e4599623a165c54a0dccdaf875))
* **fips-crypto-policies:**  improve check for module inclusion ([1ef60f9f](https://github.com/dracut-ng/dracut/commit/1ef60f9fcfb57f79532604c1ea1920ace7c21e99))
* **i18n:**  make /etc/vconsole.conf optional ([1246c4a1](https://github.com/dracut-ng/dracut/commit/1246c4a176847e8be4cfb2dd82ef1ddc9462c012))
* **img-lib:**  trim required binaries ([755c5c52](https://github.com/dracut-ng/dracut/commit/755c5c522e54a71207d075ebcba8fc83f6799e01))
* **iscsi:**
  *  attempt iSCSI login before all interfaces are up ([f30cf46e](https://github.com/dracut-ng/dracut/commit/f30cf46e5bb8919c15245325e095103c2624884e))
  *  don't require network setup for bnx2i ([cc2c48a0](https://github.com/dracut-ng/dracut/commit/cc2c48a0b3b97781e7e10e8fc9bd0a74c4c5bce2))
  *  do not install services when not using systemd ([87fefd3c](https://github.com/dracut-ng/dracut/commit/87fefd3cab7f9c611dc74a7ebc230228a7682e84))
  *  remove duplicate inst_multiple calls for iscsiadm and iscsid ([73cdd31c](https://github.com/dracut-ng/dracut/commit/73cdd31c1b086fd847affa8defc212f1186e51db))
  *  include /usr/lib/open-iscsi/startup-checks.sh if needed ([7fe7fa94](https://github.com/dracut-ng/dracut/commit/7fe7fa943748c6b746e762ab263084eb7d15a63e))
* **kernel-network-modules:**  if running inside vm, include qemu-net ([2ecdda2d](https://github.com/dracut-ng/dracut/commit/2ecdda2d28f165d26cbdb82c9fe3a2f7bab71c52))
* **lsinitrd:**  improve KERNEL_VERSION detection ([37ce14fb](https://github.com/dracut-ng/dracut/commit/37ce14fb0215c031090cac890c1c6dabcf183714))
* **lvmthinpool-monitor:**  make sure systemd is included ([359e1e9a](https://github.com/dracut-ng/dracut/commit/359e1e9a50ff77345696a8088f613c6418886cf1))
* **nfs:**
  *  do not set DRACUT_RESOLVE_LAZY for musl ([9060fe6b](https://github.com/dracut-ng/dracut/commit/9060fe6b2eda894235464fbd2aa1ba2b279971c7))
  *  use the same directory set ownership and permissions as the host ([6c3b8b2f](https://github.com/dracut-ng/dracut/commit/6c3b8b2f297657920a022e52e68c8b0c192acbbe))
* **pcsc:**  add libpcsclite_real.so.* ([bfa00c2a](https://github.com/dracut-ng/dracut/commit/bfa00c2a03b07efae5a826aa881317acea9a4ec6))
* **plymouth:**
  *  change severity of shutdown log messages ([62c79128](https://github.com/dracut-ng/dracut/commit/62c79128dac8cc2cbc5422dc7b871de1e7a54467))
  *  silence warnings ([85bb1bc6](https://github.com/dracut-ng/dracut/commit/85bb1bc6344065884bb85d6638400632f3bf3010))
  *  do not depend on dpkg-architecture ([1b374931](https://github.com/dracut-ng/dracut/commit/1b374931126cc1cc4d731930c4b0ee520a4abbf6))
* **qemu-net:**  align check logic between qemu modules ([bb7425b8](https://github.com/dracut-ng/dracut/commit/bb7425b8102f46928327bc762f653b2660643c34))
* **rngd:**  do not include the module if we can not start the service ([3c727b60](https://github.com/dracut-ng/dracut/commit/3c727b602d36d52960420ebaba1147152a603ceb))
* **shell-interpreter:**  move later in the module ordering ([8f247f2f](https://github.com/dracut-ng/dracut/commit/8f247f2faae48d2250e0ed82cef95911f0735073))
* **systemd:**
  *  systemd dlopens libbpf ([659c2681](https://github.com/dracut-ng/dracut/commit/659c268198ec9895292695b658b47d9e588513d6))
  *  include dmi-sysfs ([817dd612](https://github.com/dracut-ng/dracut/commit/817dd61252f535412f488f0a05361abdfaeedbcd))
* **systemd-ask-password:**  do not half-install systemd-ask-password-wall ([d8d11852](https://github.com/dracut-ng/dracut/commit/d8d118523f0ed74427beccec4857a92fe5ffdf7e))
* **systemd-networkd:**  depend on net-lib ([80e9d891](https://github.com/dracut-ng/dracut/commit/80e9d891dbe4b9d9244fc801dcec0dac52d16de3))
* **systemd-pcrphase:**  include systemd-pcrphase in hostonly mode ([ea6a47ed](https://github.com/dracut-ng/dracut/commit/ea6a47ede7d9c5b268bd51aac3808d8b3979a962))
* **systemd-sysext:**  install new initrd-specific units ([68a09b43](https://github.com/dracut-ng/dracut/commit/68a09b43e95a760b7f2b055e91e394dba7b968c8))
* **systemd-sysuser:**  add support for Gentoo ([1c5f45a2](https://github.com/dracut-ng/dracut/commit/1c5f45a24b34e3fb81e29f44de451bd1f9638203))
* **systemd-sysusers:**  systemd.conf no longer exists ([8f30a001](https://github.com/dracut-ng/dracut/commit/8f30a001a221f5ea668cd1bdab43f813c97b98a8))
* **systemd-tmpfiles:**
  *  passwd and group file management ([4e520c88](https://github.com/dracut-ng/dracut/commit/4e520c88d9826cc1ed7b759472f747de35fc0eee))
  *  copy 20-systemd-stub.conf into the initrd ([0df92885](https://github.com/dracut-ng/dracut/commit/0df928856150e674ce4cb04c0ceafae71d18d55b))
* **test:**  running tests on bare metal fail with syntax error ([e26a4ab9](https://github.com/dracut-ng/dracut/commit/e26a4ab9b3156660c84c2d8d39177218ec2d6bdf))
* **test-root:**  dracut-getarg and dracut-lib are no longer used for test-root ([97e502c4](https://github.com/dracut-ng/dracut/commit/97e502c444c4c19ee3892d36953138ac9e1a37c6))

#### Performance

* **base:**  /etc/initrd-release is only for systemd ([5bf724fa](https://github.com/dracut-ng/dracut/commit/5bf724fa217ccd6011be4341d30eca05427b3415))
* **hwdb:**  only include when another module requires it in hostonly ([7766da60](https://github.com/dracut-ng/dracut/commit/7766da60f5dc045b5b709849a211bebf8077162e))
* **systemd:**  remove crypto API kernel modules ([fa45d844](https://github.com/dracut-ng/dracut/commit/fa45d84469b915ede2e72111d658df18bfb60a27))

#### Features

*   default config profile ([8c15bb61](https://github.com/dracut-ng/dracut/commit/8c15bb6150934aa5ede384c6976e509ac2bf3215))
*   systemd-battery-check dracut module ([7cf47b26](https://github.com/dracut-ng/dracut/commit/7cf47b26fe2e8a1a6fcac301db74ae3dbbf523b0))
*   create a documentation site ([77e0571c](https://github.com/dracut-ng/dracut/commit/77e0571c29256e6951cc9a48c0d2ff5015a5f6b3))
* **Makefile:**
  *  roll cleaninstall target into the install target ([9825dd7b](https://github.com/dracut-ng/dracut/commit/9825dd7b271f7fa6f5d784a6de34eee3250e9a68))
  *  cleaninstall target ([dc40daa8](https://github.com/dracut-ng/dracut/commit/dc40daa81d5a09221803c0a4ea37b359931463c6))
* **base:**  create /proc if it does not exists ([ff370f55](https://github.com/dracut-ng/dracut/commit/ff370f5517ee860d51f4f27089f99a738b0ba5a1))
* **configure:**
  *  allow dracut-cpio to be disabled ([4a4ab928](https://github.com/dracut-ng/dracut/commit/4a4ab928a49e81e02104ec5466160664e59c3965))
  *  let's build dracut-cpio if cargo is installed ([89a86dcb](https://github.com/dracut-ng/dracut/commit/89a86dcb0a3248606824de50f5c63f61cfe0369c))
* **crypt:**  remove empty /etc/crypttab to allow creating it later ([23ef35d3](https://github.com/dracut-ng/dracut/commit/23ef35d3eddb49bd09df15a8f3f28244e1a4fa70))
* **dmsquash-live:**  add support for rd.live.overlay.nouserconfirmprompt ([6ac1033c](https://github.com/dracut-ng/dracut/commit/6ac1033c8d59e2324f56a2c453f14a0318cc7190))
* **dracut-init.sh:**  give --force-add precedence over --omit ([a0d92d39](https://github.com/dracut-ng/dracut/commit/a0d92d39891e4a8b61ff3a75ba46688306a1016a))
* **dracut-systemd:**  install dracut-* into /usr/bin ([00902e25](https://github.com/dracut-ng/dracut/commit/00902e25bb4b2a25a03c9ddec6b4c4c9f802650d))
* **dracut.install:**  force hostonly for kernel-install plugin ([17706f9a](https://github.com/dracut-ng/dracut/commit/17706f9a8781385769929e0407e5808c5c8c7e46))
* **fips:**  include openssl's fips.so and openssl.cnf ([97c5d43c](https://github.com/dracut-ng/dracut/commit/97c5d43ceb9d65bc0970f1e7ad44bc43bc93fc26))
* **livenet:**  get live image size from TFTP servers ([93df9ad2](https://github.com/dracut-ng/dracut/commit/93df9ad26122d3d4c0120e19c8da78b7cc69e653))
* **lsinitrd.sh:**  look for initrd in /usr/lib/modules/ ([f01eec69](https://github.com/dracut-ng/dracut/commit/f01eec692d222232c821426f453d3c66411ee34e))
* **nvmf:**  enable other shells (dash) not just bash ([43707cab](https://github.com/dracut-ng/dracut/commit/43707cabc86ab1d4a7f040ccfa2d2d673d00ce0e))
* **systemd-battery-check:**  always include the module if possible ([961daa9d](https://github.com/dracut-ng/dracut/commit/961daa9db49023c091fa87c86561ecb7eb371678))
* **systemd-emergency:**  install rescue and emergency targets ([be7e87fb](https://github.com/dracut-ng/dracut/commit/be7e87fbb7d7122cdc6386bac4e7bc5d32c6ad2f))
* **systemd-sysusers:**  run systemd-sysusers as part of the build process ([f3dacc01](https://github.com/dracut-ng/dracut/commit/f3dacc013d90bd2c0bbfa04f5f9b167b65298440))

#### Contributors

- Jo Zzsi <jozzsicsataban@gmail.com>
- Benjamin Drung <benjamin.drung@canonical.com>
- Ian Wienand <iwienand@redhat.com>
- Laszlo Gombos <laszlo.gombos@gmail.com>
- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- Pavel Valena <pvalena@redhat.com>
- dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
- Martin Wilck <mwilck@suse.de>
- Fernando Fernandez Mancera <ffmancera@riseup.net>
- Jochen Sprickerhof <git@jochen.sprickerhof.de>
- Andrew Ammerlaan <andrewammerlaan@gentoo.org>
- David Härdeman <david@hardeman.nu>
- George Mileka <gmileka@microsoft.com>
- Manuel Fombuena <fombuena@outlook.com>
- Mike Gilbert <floppym@gentoo.org>
- Nowa Ammerlaan <andrewammerlaan@gentoo.org>
- Nowa Ammerlaan <nowa@gentoo.org>
- Patrick Schleizer <adrelanos@whonix.org>

dracut-105
=============

Resolve a regression in release v104 that impacts generated initrds when both systemd and i18n dracut modules are included.

#### Bug Fixes

* **dmsquash-live:**  checkisomd5 is installed into /usr/bin ([39887041](https://github.com/dracut-ng/dracut/commit/398870413e98d85a574b06ca69e8613a1ac209be))
* **man:**
  *  use US English spelling for initialization ([c12a018e](https://github.com/dracut-ng/dracut/commit/c12a018eb89febfa550d478a97d4bfbdd39bda90))
  *  correct spelling of initramfs ([b5ada6cc](https://github.com/dracut-ng/dracut/commit/b5ada6ccb618eec005f01b40a9f94eb149ff5b3d))
* **systemd:**  remove typo from the dracut module name ([7d998705](https://github.com/dracut-ng/dracut/commit/7d998705e15949dd4d62d2af9ae35171316b7ca5))
* **systemd-cryptsetup:** change the ordering for consistency ([43581cd0](https://github.com/dracut-ng/dracut/commit/43581cd065821e82654237f0dd5493e3b828601f))
* **udev-rules:**  move relevant rules from systemd ([1ef30c83](https://github.com/dracut-ng/dracut/commit/1ef30c832f4a0b6e82b85fd6576057eae22f8d41))

#### Contributors

- Jo Zzsi <jozzsicsataban@gmail.com>
- Benjamin Drung <benjamin.drung@canonical.com>

dracut-104
=============

New dracut modules:
* shell-interpreter: meta package for improved shell selection
* fips-crypto-policies: make c-p follow FIPS mode automatically
* squash-lib: code shared by 95squash-{squashfs,erofs}

Removed dracut modules:
* ifcfg: no longer needed for networking
* mksh: lack of interest to maintain

Notable new features:
* add --add-confdir option to dracut
* new dracut configuration profiles under dracut.conf.d/ (e.g. for uki)
* systemd-udevd: make systemd-sysctl, systemd-modules-load optional

Notable bug fixes:
* crypt: include systemd-cryptsetup module when needed
* udev-rules: move installation of libkmod to udev-rules module
* busybox: install busybox symlinks later in the generation process
* nvmf: install (only) required nvmf modules
* systemd: include systemd config files from /usr/lib/systemd
* systemd: trigger systemd-vconsole-setup.service only on demand
* multipath: include module with "find_multipaths strict"
* nfs: include also entries from /usr/lib/{passwd,group}
* network: handle '-m network'
* systemd-networkd: remove basename dependency
* remove obsolete syntax for many command line options without the rd. prefix

The project builds test containers daily for the following Linux distributions:

Alpine, Arch, Debian (amd64 and arm64), Fedora (amd64 and arm64), Gentoo, openSUSE, Ubuntu, Void
These Linux distributions test dracut in various configurations (systemd/OpenRC/runit, glibc/musl, dhclient/NetworkManager/systemd-networkd).

#### Features

*   config example for cloud provider uki vm ([cc0a0e42](https://github.com/dracut-ng/dracut/commit/cc0a0e420df6120fa81b8c12b47865dc7825d1f4))
*   add common config when networking is not desired ([9ffabd59](https://github.com/dracut-ng/dracut/commit/9ffabd5916605be5052faa1256f29feafbc83b1e))
* **busybox:**  use busybox --install to install itself ([3975e26a](https://github.com/dracut-ng/dracut/commit/3975e26a84cd8645b15d0a863263a63da93650e0))
* **dracut:**  detect kernel initrd support ([b41c2401](https://github.com/dracut-ng/dracut/commit/b41c24019321232a22062955254bd3eb2f002b4a))
* **dracut-functions:**  check more paths ([ede2a05a](https://github.com/dracut-ng/dracut/commit/ede2a05a6e44f6c73eca79e1fd4803927d334511))
* **dracut-init.sh:**  allow changing the destination directory for inst et al ([3ad7e6c2](https://github.com/dracut-ng/dracut/commit/3ad7e6c23bdcac7c7f6adc8a2cb31bab3c37038a))
* **dracut-initramfs-restore:**  unpack erofs images ([ce83d38d](https://github.com/dracut-ng/dracut/commit/ce83d38dfa30507382b00219f9e009dbb10e3c72))
* **dracut.sh:**  add --add-confdir option ([6107f5e5](https://github.com/dracut-ng/dracut/commit/6107f5e54fb82f1c00285a4cc709b04f29eee460))
* **fips:**  add support for UKIs ([1000265a](https://github.com/dracut-ng/dracut/commit/1000265a185c5156e0e0ba218bca23a9f1031f60))
* **fips-crypto-policies:**  make c-p follow FIPS mode automatically ([bd3c1e1c](https://github.com/dracut-ng/dracut/commit/bd3c1e1cc2f656f7ee4ff47e00ca716d52a86a3d))
* **lsinitrd:**  add support for erofs images ([2a3bc5af](https://github.com/dracut-ng/dracut/commit/2a3bc5af412929a638559a9e530c00a53932a606))
* **pcmcia:**  only include when another module requires it ([ea4199b3](https://github.com/dracut-ng/dracut/commit/ea4199b38c097fa4dc059dd52740af91111145b5))
* **rescue:**  move command line arguments to 50-rescue.conf ([d24917fa](https://github.com/dracut-ng/dracut/commit/d24917fa1907d67d3e422139a2bf0866bf0dc26d))
* **shell-interpreter:**  meta package for improved shell selection ([e1fcfe64](https://github.com/dracut-ng/dracut/commit/e1fcfe64fb439ae71fc6babcaac3c6bc834b00a9))
* **squash:**
  *  add module 95squash-erofs ([ebc9e84d](https://github.com/dracut-ng/dracut/commit/ebc9e84dd3bdcb3fc2899431cb46bc12bd986294))
  *  split 95squash-squashfs from 99squash ([5d03cc3b](https://github.com/dracut-ng/dracut/commit/5d03cc3be869268ec07cf2c2ec74f008dde3e110))
  *  move mksquashfs to 99squash/modules-setup ([b5482f07](https://github.com/dracut-ng/dracut/commit/b5482f0726e02e6c6484377725345109c204fb03))
* **systemd:**  always install libsystemd libraries ([921792f2](https://github.com/dracut-ng/dracut/commit/921792f201e954de461d3b551e01b5369d666db8))
* **systemd:**  include systemd config files from /usr/lib/systemd ([6c99c073](https://github.com/dracut-ng/dracut/commit/6c99c07327b9600f18fcf97564f427610453a771))
* **test-root:**  only include debug module if V is set to 2 ([8974fea2](https://github.com/dracut-ng/dracut/commit/8974fea2f92a63a10e48ad9aee9ccc02c5e78883))

#### Bug Fixes

*   install test infrastructure ([a0d12aa7](https://github.com/dracut-ng/dracut/commit/a0d12aa7dd6d4304955de1407a35dda87ee86b54))
*   typo in variable name ([76b2f1a9](https://github.com/dracut-ng/dracut/commit/76b2f1a9b52afd4203c1d0e6afb57314bbfe8407))
* **Dockerfile-Gentoo:**  explicitly pull in all build dependencies ([2f8ea1c9](https://github.com/dracut-ng/dracut/commit/2f8ea1c90175b3fbe8c98621776a7d3456c78c56))
* **Makefile:**  install dracut config examples under /usr ([0d369e3e](https://github.com/dracut-ng/dracut/commit/0d369e3e30935dffe48dfff1e90463868e7f804a))
* **base:**
  *  init from base is not needed when systemd is enabled ([ae94b24f](https://github.com/dracut-ng/dracut/commit/ae94b24f2370db490593dd35b2cfea57aa7dbfe5))
  *  remove the undocumented real_init, realinitpath and rd.distroinit ([b1dbe859](https://github.com/dracut-ng/dracut/commit/b1dbe859a9b6ca4bc60a0bf94ace660414207b51))
* **busybox:**
  *  install busybox symlinks later in the generation process ([4e78a870](https://github.com/dracut-ng/dracut/commit/4e78a8705e19562f5659e352612e50905c4be12a))
  *  install busybox symlinks manually ([95ba0327](https://github.com/dracut-ng/dracut/commit/95ba03270eb3297103cba276c2925ecc1b762926))
* **crypt:**
  *  include systemd-cryptsetup module when needed ([8907ba12](https://github.com/dracut-ng/dracut/commit/8907ba124e9dcd57049c2ccb4fd20b98b3bd83c2))
  *  install dm_crypt module in non-hostonly mode as well ([59af2fff](https://github.com/dracut-ng/dracut/commit/59af2fff515539e4b47ddc955d0c61a3829c85c4))
* **dracut:**
  *  --list-modules should imply --no-kernel as well ([bd7736e9](https://github.com/dracut-ng/dracut/commit/bd7736e9823d3be580d6320e2cefad97d0b33edd))
  *  don't apply aggressive strip to kernel modules ([a1c51af1](https://github.com/dracut-ng/dracut/commit/a1c51af1bf5809a8f6deb246ef6ae3f25608d6a3))
  *  do not add all lib subdirs to `LD_LIBRARY_PATH` with `--sysroot` ([d0c82322](https://github.com/dracut-ng/dracut/commit/d0c82322ce1b44e72539b6dd537711afb68f081e))
  *  ldd output borked with `--sysroot` ([e0b87682](https://github.com/dracut-ng/dracut/commit/e0b876823d9c608db7132cab9e5edd62543a27ae))
  *  re-enable extended attributes in containers ([c964a56f](https://github.com/dracut-ng/dracut/commit/c964a56fde168212422fdf37ecb835dfe409f4a7))
* **dracut-fuctions.sh:**  avoid reading the wrong kconfig ([d8fb0ef8](https://github.com/dracut-ng/dracut/commit/d8fb0ef8d9d6c0bada3e21e7a3801e5ba9fc2cdb))
* **dracut-functions:**  allow for \ in get_maj_min file path ([91b1574c](https://github.com/dracut-ng/dracut/commit/91b1574c4a19be297b893791192049612467694b))
* **dracut-functions.sh:**  only return block devices from get_persistent_dev ([6611c6e4](https://github.com/dracut-ng/dracut/commit/6611c6e4a0166bec50cc567b708ec7265dc82682))
* **dracut-init.sh:**  add module to mods_to_load before checking dependencies ([d0f8fde5](https://github.com/dracut-ng/dracut/commit/d0f8fde5668cfd7fda1d15824e268b4949b4fd04))
* **dracut-install:**
  *  use correct data type for pid ([36dc45ca](https://github.com/dracut-ng/dracut/commit/36dc45ca74ba675ac6a331459d850a15fdcbb2d6))
  *  handle correctly sysrootdir with trailing '/' ([1c44cd71](https://github.com/dracut-ng/dracut/commit/1c44cd71a87967c5d8094a3d37ab2598dbd1ef12))
  *  do not assume handled path starts with sysrootdir ([7bc1f538](https://github.com/dracut-ng/dracut/commit/7bc1f5383df58ed93ad4827634042f92ade4b20a))
  *  resolve -Wextra warnings ([8de0258d](https://github.com/dracut-ng/dracut/commit/8de0258d71dc5600d715d7534471e35b2b75c7be))
  *  refuse empty DRACUT_LDD environment variable ([a9e11447](https://github.com/dracut-ng/dracut/commit/a9e1144713056248c8ca0e0e4a2f3a08a12b89b2))
* **dracut-systemd:**  include systemd-cryptsetup module when needed ([e0e5424a](https://github.com/dracut-ng/dracut/commit/e0e5424a7b5e387ccb70e47ffea5a59716bf7b76))
* **dracut.sh:**
  *  exit when installing the squash loader fails ([abac41d0](https://github.com/dracut-ng/dracut/commit/abac41d0fa3c69dd4dc717fedd61502affa2799e))
  *  use only compressor that kernel supports ([cc17951e](https://github.com/dracut-ng/dracut/commit/cc17951ec350d0e3a8f95550579d4515c18a4649))
  *  account for the kernel being named kernel ([c520f3a4](https://github.com/dracut-ng/dracut/commit/c520f3a49ddb7b7225cdac4dd3c4d9f68e7d105c))
* **fips-crypto-policies:**  make it depend on fips dracut module ([a2096daf](https://github.com/dracut-ng/dracut/commit/a2096dafdbfc88eed91ce34b1f4d27e7eb7ca839))
* **hwdb:**  only install /etc/udev/udev.hwdb in hostonly mode ([f2b1491f](https://github.com/dracut-ng/dracut/commit/f2b1491f8461c331f501680291d6ceed6c2a718e))
* **lsinitrd:**  check skipcpio file directly ([2815f021](https://github.com/dracut-ng/dracut/commit/2815f021fd7947364c4344da479803983ffaba25))
* **lvm:**  clean up whitespace in messages ([5e9cb283](https://github.com/dracut-ng/dracut/commit/5e9cb2832f5b129dbbfdd3e9c040da978e960f56))
* **man:**  update description of the --gzip option ([206b5448](https://github.com/dracut-ng/dracut/commit/206b54481ccc031763714052545c6e7779ea3c5e))
* **multipath:**  include module with "find_multipaths strict" ([1e802f15](https://github.com/dracut-ng/dracut/commit/1e802f15fee3d6402d83e0efefef8bb88c5a33e3))
* **network:**
  *  call both check_module and module_check ([c81c9552](https://github.com/dracut-ng/dracut/commit/c81c9552650971717f99118a295c3c3840da3209))
  *  handle '-m network' ([c4b57722](https://github.com/dracut-ng/dracut/commit/c4b57722fbe65dce49105ad264dde2c2bbfc8a41))
* **nfs:**  include also entries from /usr/lib/{passwd,group} ([d954e3a9](https://github.com/dracut-ng/dracut/commit/d954e3a9e83c28e1509186c6a668a6f6c0bd4591))
* **nvmf:**
  *  install (only) required nvmf modules ([3748ed4d](https://github.com/dracut-ng/dracut/commit/3748ed4db5255c516cd60c2d710532d79878a498))
  *  require NVMeoF modules ([41332702](https://github.com/dracut-ng/dracut/commit/4133270236f99d2196b2c1d05dfab76aae2f8092))
* **release:**  improve commit message ([267d002c](https://github.com/dracut-ng/dracut/commit/267d002cbb63a59d47a2d7273d62757f9763b4d2))
* **rescue:**  make rescue always no-hostonly ([224c0091](https://github.com/dracut-ng/dracut/commit/224c00914bfb4ba1dee48e094ebb137facfd5947))
* **rngd:**  install system service file ([a9528201](https://github.com/dracut-ng/dracut/commit/a9528201bea5182c72556731ef7944259fbe3fc8))
* **squash:**
  *  remove cyclic dependency ([5f6b6fa4](https://github.com/dracut-ng/dracut/commit/5f6b6fa4dc0b2f6a174e98f557fd595bdd92d361))
  *  use 99busybox instead of installing it manually ([69ebcb58](https://github.com/dracut-ng/dracut/commit/69ebcb5850b5ceb27d5fd5fee6a5d2857d38b828))
  *  explicitly create required directories ([d23b0eea](https://github.com/dracut-ng/dracut/commit/d23b0eeaa6a985b60b3a7f278f8e8fb1a63a0ae3))
* **squash-erofs:**  properly exclude $squashdir ([323af181](https://github.com/dracut-ng/dracut/commit/323af1817405b64a154ae1b01f5aca180a2801fa))
* **squash-lib:**  harden against empty $initdir ([924e2e85](https://github.com/dracut-ng/dracut/commit/924e2e85d9731b4e1d3852bc3a4a5d045024051a))
* **systemd:**
  *  do not set unused target as the default ([982735c7](https://github.com/dracut-ng/dracut/commit/982735c790cabade82f520ddda8e6c3733cb6571))
  *  /sbin/init is not required inside initrd ([a066b07f](https://github.com/dracut-ng/dracut/commit/a066b07fbdc5cad5c3cb9873d987a432cbed14e2))
  *  systemd-vconsole-setup has a dependency on loadkeys ([55517460](https://github.com/dracut-ng/dracut/commit/5551746088633116a28f3ded9d7003f378b6cd17))
  *  remove duplicate systemd cryptsetup targets ([ad520855](https://github.com/dracut-ng/dracut/commit/ad520855113d99d7551a7ab6c19870736f72cbc4))
  *  make nologin optional ([953b48a7](https://github.com/dracut-ng/dracut/commit/953b48a7e7a4057c7d694c29cc30ea993b946e55))
  *  move installation of libkmod to udev-rules module ([ef0972fe](https://github.com/dracut-ng/dracut/commit/ef0972fe5349bdf6e821cb79a47cf412caf99059))
* **systemd-cryptsetup:**  install cryptsetup-pre.target ([181e1f11](https://github.com/dracut-ng/dracut/commit/181e1f116b74d1e4ee400f72f7440b78a4c4d1f1))
* **systemd-initrd:**  add base as dependency ([56c84cde](https://github.com/dracut-ng/dracut/commit/56c84cdece4bff04ed9db213f49d052d994df04d))
* **systemd-networkd:**
  *  remove basename dependency ([2bb74448](https://github.com/dracut-ng/dracut/commit/2bb7444850b57893a6c6c875da69109b83da5090))
  *  make sure default network is always last ([e1dfdaca](https://github.com/dracut-ng/dracut/commit/e1dfdaca22d5074a6a3d8fcf6df080752b84803d), closes [#618](https://github.com/dracut-ng/dracut/issues/618))
* **systemd-sysctl:**  systemd-modules-load is not a dependency ([4fb67460](https://github.com/dracut-ng/dracut/commit/4fb6746085aaceed4822bf7c8ee13193e2ef46fe))
* **systemd-udevd:**  make systemd-sysctl, systemd-modules-load optional ([1de08390](https://github.com/dracut-ng/dracut/commit/1de083908d5065af585c0a657c43f8ad16a19868))
* **test:**  always install kernel modules ([9c79e226](https://github.com/dracut-ng/dracut/commit/9c79e22694332a0e6b59f92391fe7e05919de485))
* **udev-rules:**
  *  remove systemd-specific rules ([6243b7b6](https://github.com/dracut-ng/dracut/commit/6243b7b623680aa1f431c962832a6f877b60afdb))
  *  move *-persistent-storage.rules to rootfs-block ([d67251aa](https://github.com/dracut-ng/dracut/commit/d67251aaa5529e521e0a0ca4d28dc938a98a6226))
  *  install dropins for udev.conf ([bdaa4e5b](https://github.com/dracut-ng/dracut/commit/bdaa4e5b0145214fa154465a92a80783a46aba9a))
* **watchdog:**  change the priority of watchdog kernel modules ([0097ded1](https://github.com/dracut-ng/dracut/commit/0097ded1de21f8a7f9453a5e1c03195f985a053f))

#### Performance

* **systemd-initrd:**
  *  do not depend on base module ([06074459](https://github.com/dracut-ng/dracut/commit/06074459b9536a03f67bc6b6e09da0b2b510bd67))
  *  initrd.target is already the default ([b7b4f039](https://github.com/dracut-ng/dracut/commit/b7b4f03987a0ffbd2b8ee585b84f852e512f000d))

#### Contributors

- Jo Zzsi <jozzsicsataban@gmail.com>
- Laszlo Gombos <laszlo.gombos@gmail.com>
- Philipp Rudo <prudo@redhat.com>
- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- Pavel Valena <pvalena@redhat.com>
- Andrew Ammerlaan <andrewammerlaan@gentoo.org>
- Marcos Mello <marcosfrm@gmail.com>
- Martin Wilck <mwilck@suse.de>
- Matteo Croce <teknoraver@meta.com>
- Ondrej Kubik <ondrej.kubik@canonical.com>
- Alexander Tsoy <alexander@tsoy.me>
- Clemens Lang <cllang@redhat.com>
- David Teigland <teigland@redhat.com>
- Dorina Kovacs <princessdorinakovacs@gmail.com>
- Fabian Henze <1144183+flyser@users.noreply.github.com>
- Fabian Vogt <fvogt@suse.de>
- Jochen Sprickerhof <git@jochen.sprickerhof.de>
- Kairui Song <kasong@tencent.com>
- Lichen Liu <lichliu@redhat.com>
- Mike Gilbert <floppym@gentoo.org>
- Mike Schwarz <xurubezi@gmail.com>
- Neal Gompa <neal@gompa.dev>
- Timo Rothenpieler <timo@rothenpieler.org>
- Vitaly Kuznetsov <vkuznets@redhat.com>

dracut-103
=============

New dracut modules introduced by this release:
 - hwdb: separate out hwdb module

Notable new features:
 - erofs support for dmsquash-live module
 - install platform/chrome modules on ARM/RISC-V
 - force the inclusion of crypttab entries with x-initrd.attach
 - configuration files for common packaging options (50-hostonly.conf.example)

Commits that resolve notable regressions:
 - perf(dracut-install): memoize find_kmod_module_from_sysfs_node
 - perf(dracut-install): use driver/module sysfs dirs for module name
 - fix(crypt): decryption when rd.luks.name is set
 - fix(systemd-pcrphase): make tpm2-tss an optional dependency

The project builds test containers daily for the following Linux distributions:
 - Alpine, Arch, Debian (amd64 and arm64), Fedora (amd64 and arm64), Gentoo, openSUSE, Ubuntu, Void
 - These Linux distributions test dracut in various configurations (systemd/OpenRC/runit, glibc/musl, dhclient/NetworkManager/systemd-networkd).

#### Features

*   add common config for Integrity Measurement ([5d9fe8c5](https://github.com/dracut-ng/dracut/commit/5d9fe8c5020ff7e895ddfc3a88cab98d4e7a67ea))
*   add additional common configs ([69e119da](https://github.com/dracut-ng/dracut/commit/69e119daea14cb25fed2ed8134d628f3b233108d))
* **crypt:**  force the inclusion of crypttab entries with x-initrd.attach ([61ab3386](https://github.com/dracut-ng/dracut/commit/61ab3386e83a9bd219dcaa05c6499fec56d092b8))
* **debug:**  add findmnt to help debugging ([41d61114](https://github.com/dracut-ng/dracut/commit/41d61114e2eaca20824660aafc0ffae56d09d395))
* **dmdquash-live:**  add support for using erofs ([ca5ae5d3](https://github.com/dracut-ng/dracut/commit/ca5ae5d3466eec40d118fc96d450478aa6faebb6))
* **dracut:**  search for zstd compressor first ([9663307c](https://github.com/dracut-ng/dracut/commit/9663307ceb244ae6293e090f418f9888d6dff8bf))
* **dracut-install:**
  *  configure if weak dep is still not supported in kmod ([77c3efa6](https://github.com/dracut-ng/dracut/commit/77c3efa67e1ad724a441eb3341b3fc8a3d9684b6))
  *  add weak dependencies support ([8517a6be](https://github.com/dracut-ng/dracut/commit/8517a6be5e20f4a6d87e55fce35ee3e29e2a1150))
  *  add hashmap_get_exists() ([2b13d74d](https://github.com/dracut-ng/dracut/commit/2b13d74d4429c8c242a610f10b8389c7e46ff835))
* **hwdb:**  separate out hwdb module ([3c5d5e39](https://github.com/dracut-ng/dracut/commit/3c5d5e398e80b51527420bd9112c37536df219a5))
* **kernel-modules:**  install platform/chrome modules on ARM/RISC-V ([e69e4132](https://github.com/dracut-ng/dracut/commit/e69e41326241c8fa538a5c4383c16ddbab296e6f))
* **lsinitrd.sh:**  support configurable initrd filenames ([7c11c8cf](https://github.com/dracut-ng/dracut/commit/7c11c8cfa4d12389705f447efb130a675cf48b53))
* **multipath:**  warn if included with no multipath devices and no user conf ([ae1b1003](https://github.com/dracut-ng/dracut/commit/ae1b1003305f1553c057970d07a917deb255b7ef))
* **qemu:**  include the virtio_crypto kernel module ([0fe20f85](https://github.com/dracut-ng/dracut/commit/0fe20f85d02cd8496d27b85844307afc9523026b))
* **test:**
  *  add erofs-utils to the containers ([e11bc8bf](https://github.com/dracut-ng/dracut/commit/e11bc8bfbd86b8eddb1f4c4f75ba35b1c97fffa1))
  *  support V=2 without logtee ([3f005c8a](https://github.com/dracut-ng/dracut/commit/3f005c8aa3436d70328a833d551a6e9a175c1332))

#### Bug Fixes

*   check for searched initrds to be present ([9c396ce2](https://github.com/dracut-ng/dracut/commit/9c396ce29fc9e2ced6ebddbdf43fb31a672c2c37))
*   rename dracut.conf.d .conf files to conf.example ([ddc9e4e9](https://github.com/dracut-ng/dracut/commit/ddc9e4e922e91e0a2ea5d17035c45d8dab674b6f))
*   disable SC2317 for calls by for_each_host_dev_and_slaves ([23c9d85a](https://github.com/dracut-ng/dracut/commit/23c9d85a1fdcc31d175a27fd2dc3ac2789e528ef))
*   quote single CTTY parameter ([61d93421](https://github.com/dracut-ng/dracut/commit/61d93421aa949c9022efab37aafadb2203aba537))
*   address shellcheck SC2166 ([d3802b10](https://github.com/dracut-ng/dracut/commit/d3802b10b3f9d1f887546ea42b0e014c8ec76d74))
*   move shellcheck SC3045 override to occurrences ([e1728ee9](https://github.com/dracut-ng/dracut/commit/e1728ee9763dc9917de77dcb2d128d6363b3f05f))
* **01fips:**  replace read -d that is not supported by dash ([15b94c44](https://github.com/dracut-ng/dracut/commit/15b94c4403188cafc6f401f1430bd3692bd7cef8))
* **90kernel-modules:**  install blk modules using symbol blk_alloc_disk ([194ef8eb](https://github.com/dracut-ng/dracut/commit/194ef8ebbf113c48b97ada4981bf50e87d6b0204))
* **Dockerfile-Gentoo:**  add requirements for systemd-pcrphase ([f7e19b3a](https://github.com/dracut-ng/dracut/commit/f7e19b3a11a2e03c01984a13df119184a6206997))
* **TEST-35-ISCSI-MULTI:**  increrase storage space ([9f183a98](https://github.com/dracut-ng/dracut/commit/9f183a9815c480b92a05e7c92abef4f6281350fb))
* **TEST-40-NBD:**
  *  disable broken tests ([eb32b30b](https://github.com/dracut-ng/dracut/commit/eb32b30b73b6846048d219a7b304bc8e57c53119))
  *  return actual test run result from test_run() ([cfe3ce3c](https://github.com/dracut-ng/dracut/commit/cfe3ce3cee04669291e7b412a1f9730a59ad8f66))
  *  enable serial console for test runs ([1993786f](https://github.com/dracut-ng/dracut/commit/1993786f8aa183ce44705fce2a748cefdd2ed5c9))
  *  don't double-pass test dir to marker check ([5928c938](https://github.com/dracut-ng/dracut/commit/5928c938590c69ef297d2f86dd0eb27080c0e03f))
* **TEST-NFS:**  use --add instead of --modules to create test-makeroot ([0a94eab6](https://github.com/dracut-ng/dracut/commit/0a94eab66d330dd3d01593fd474103e8fb9e4ad7))
* **convertfs:**
  *  drop unused find_mount function ([04628fc4](https://github.com/dracut-ng/dracut/commit/04628fc4ae37bb0f32c426e9a3661f9bb2ead1ab))
  *  disable SC2317 for EXIT trap function ([6668694d](https://github.com/dracut-ng/dracut/commit/6668694df0895a9aa61f859b8b618a4bb65b3178))
  *  quote single CP_HARDLINK variable ([00ba4dae](https://github.com/dracut-ng/dracut/commit/00ba4dae4e392942c9090723133f3acba1731962))
* **crypt:**  decryption when rd.luks.name is set ([015a0fa6](https://github.com/dracut-ng/dracut/commit/015a0fa63367f6e48fd9edd7808305877276ed7f))
* **dbus:**  drop unreachable return statement ([c3764b92](https://github.com/dracut-ng/dracut/commit/c3764b925ae0a9aab2a2db86a77a02e48f6a4d96))
* **dbus-daemon:**  actually enable the dbus service and socket ([71f2ff50](https://github.com/dracut-ng/dracut/commit/71f2ff50f55f24b4435aff6143fc3041db6f3d1d))
* **dmsquash-live:**
  *  make sure erofs module is installed ([e52cf3c1](https://github.com/dracut-ng/dracut/commit/e52cf3c128b3b818a5830b6d92e257084d34b3dc))
  *  quote variables ([5391fa2e](https://github.com/dracut-ng/dracut/commit/5391fa2e671f3ed78e0346bd1f7de47abcb7fe73))
* **dmsquash-live-autooverlay:**  quote variables ([24ab9e66](https://github.com/dracut-ng/dracut/commit/24ab9e66d0421eb8441b62f5a7dad3b7e3e0324f))
* **dracut:**
  *  microcode loading named .initramfs ([cd3f04ab](https://github.com/dracut-ng/dracut/commit/cd3f04ab9d7521f59bbd7fde489584aba5db5384))
  *  address shellcheck SC2004 ([79e372de](https://github.com/dracut-ng/dracut/commit/79e372def132818df988f821d3e60dd9137fee01))
  *  quote strip_cmd variable ([538689bc](https://github.com/dracut-ng/dracut/commit/538689bc723f096341fbf780fd7b4ec1f023e085))
* **dracut-catimages.sh:**  drop unused dwarning function ([34bf2fe4](https://github.com/dracut-ng/dracut/commit/34bf2fe40308ee67a3d555cc475af230f983e958))
* **dracut-functions:**  avoid awk in get_maj_min() ([ec7efd57](https://github.com/dracut-ng/dracut/commit/ec7efd5701e9a1b24f2e85666d625fb1fe46ce86))
* **dracut-init:**  change lookup order for rules files ([46932e33](https://github.com/dracut-ng/dracut/commit/46932e33536e2223f297dc7369bd14d8b578caa3))
* **dracut-init.sh:**
  *  clarify the error message ([f83d8f90](https://github.com/dracut-ng/dracut/commit/f83d8f90a15812ea260032d05885c989665b5933))
  *  quote dracutbasedir variable ([5969b230](https://github.com/dracut-ng/dracut/commit/5969b2306d65c231a2a6be89f1ca13862287dac3))
* **dracut-initramfs-restore.sh:**  correct initrd globbing ([cc5e8d6f](https://github.com/dracut-ng/dracut/commit/cc5e8d6f9ff965e91a749a653c7114cb04edb358))
* **dracut-install:**  copy xattr when use clone ioctl ([3e1d0bc1](https://github.com/dracut-ng/dracut/commit/3e1d0bc1df6fcc5649e38d1016f05712f634b2f5))
* **dracut-lib:**
  *  quote _ctty variable ([22910365](https://github.com/dracut-ng/dracut/commit/2291036520413379932e41ff22d704cd3397e76f))
  *  quote var variable ([7a277629](https://github.com/dracut-ng/dracut/commit/7a277629b5c37ab5bf7a39605e8d1546c0086835))
  *  quote _b variable ([e4ec0d33](https://github.com/dracut-ng/dracut/commit/e4ec0d3397d0f10abb69a4c91d1c6b448f986d02))
* **dracut-logger.sh:**
  *  disable SC2317 for logger functions ([c77365ce](https://github.com/dracut-ng/dracut/commit/c77365ce2c38cd9d1cd4aab27edd0fab14950ced))
  *  quote _dlogfd variable ([89eddc42](https://github.com/dracut-ng/dracut/commit/89eddc420f00f0c1b790b960c1e5abc348b98722))
* **dracut.sh:**  drop unused read_arg function ([a9ea0175](https://github.com/dracut-ng/dracut/commit/a9ea01755edb4a63518234b52c25e240b4c6e1d3))
* **fips:**  remove reference to kernel module zlib in fips module ([22f451d5](https://github.com/dracut-ng/dracut/commit/22f451d57585cb01ee5a84ef73d104110cb7d422))
* **iscsi:**  address shellcheck SC2319 ([54676c83](https://github.com/dracut-ng/dracut/commit/54676c83d1101d709a958d1a87e6d8508b360c3b))
* **lsinitrd.sh:**  disable SC2317 for cat functions ([f62049b2](https://github.com/dracut-ng/dracut/commit/f62049b251d66c0c8f755a0a2e769cfe90b9b901))
* **lunmask:**  quote LUN variable ([d20be112](https://github.com/dracut-ng/dracut/commit/d20be112231d89e220f97bb4adb0b5db572bbc24))
* **lvmthinpool-monitor:**  adress shellcheck SC2319 ([199f4108](https://github.com/dracut-ng/dracut/commit/199f410861d2e2204ec77045fcf37a21fe31bdfe))
* **man:**  clarify semantics for --kernel-cmdline ([aba502f3](https://github.com/dracut-ng/dracut/commit/aba502f324b957bc625462b39748f4aca1650225))
* **mdraid:**  try to assemble the missing raid device ([3fd43858](https://github.com/dracut-ng/dracut/commit/3fd4385873bb82ae9f759ef5af32bf1732d298b4))
* **multipath:**
  *  omit module if included with no multipath devices ([377d52cb](https://github.com/dracut-ng/dracut/commit/377d52cb9867dc4074fe78965e1bfcdf80be14a1))
  *  omit module if included with no multipath devices ([4957ffa9](https://github.com/dracut-ng/dracut/commit/4957ffa935ea8c393c8fed867f6051da4ca43d58))
* **net-lib:**  require and install only the necessary binaries ([29609268](https://github.com/dracut-ng/dracut/commit/29609268b74472cbf4ac02f83e1edd9609169de2))
* **network:**  deprioritize connman for network selection ([dec4978f](https://github.com/dracut-ng/dracut/commit/dec4978fa06252d69c63a5939adb6d706195fe96))
* **network-legacy:**  quote bridgename variable ([bc166ece](https://github.com/dracut-ng/dracut/commit/bc166ece9924793c53ac43ce7505669d5b84b829))
* **nfs:**
  *  support rpcbind user named _rpc ([4a236f01](https://github.com/dracut-ng/dracut/commit/4a236f015905f598e2976ae6f0f460ec9a567f2b))
  *  quote rpcpipefspath variable ([58a46715](https://github.com/dracut-ng/dracut/commit/58a46715598185d0fd836847abc2fdd6408a736b))
* **release:**  version lock clog ([58d4d7d6](https://github.com/dracut-ng/dracut/commit/58d4d7d683cfaa1455ed3be8430613e8251cfeab))
* **rt:**  use singular argument for timeout value ([e2e6579a](https://github.com/dracut-ng/dracut/commit/e2e6579afa49b7878bf03327f16b2ddabd139380))
* **shell-completion:**  remove hashbang from bash completions ([c50e742c](https://github.com/dracut-ng/dracut/commit/c50e742c530f114c50ef9a2b63e0cc6d0150838a))
* **syslog:**  quote conf variable ([28e1b17b](https://github.com/dracut-ng/dracut/commit/28e1b17b750ef7d8a269fa50d7ab0e43fd7b3ebd))
* **systemd:**  check for systemd-vconsole-setup.service ([5a3ad259](https://github.com/dracut-ng/dracut/commit/5a3ad259aca1a0ed09dccdb0db5873cd5b94f666))
* **systemd-hostnamed:**
  *  also enable socket units ([133978d9](https://github.com/dracut-ng/dracut/commit/133978d96c9dbf02e9bfbf8214111540c6e1d6ab))
  *  add missing systemd-hostnamed.socket ([f25bb1e2](https://github.com/dracut-ng/dracut/commit/f25bb1e2b27cb3246e6fc51a33b13775e4f4ffce))
* **systemd-networkd:**
  *  remove default network if others were generated ([02a1ea4b](https://github.com/dracut-ng/dracut/commit/02a1ea4b308aeb339dcddf90b489b7de86e12149))
  *  add support for proper netroot invocation ([0e1e7871](https://github.com/dracut-ng/dracut/commit/0e1e78711502347412e2c0a0621773f034332499))
  *  this module depends on systemd ([1aa2e4ff](https://github.com/dracut-ng/dracut/commit/1aa2e4ffe7e04bb57ca57bc7cd3d38a7d5d3dc33))
* **systemd-pcrphase:**
  *  make tpm2-tss an optional dependency ([a2193b71](https://github.com/dracut-ng/dracut/commit/a2193b71f7be75f719eec29faacae36ab25e9147))
  *  in hostonly mode do not try to include systemd-pcrphase ([96d153fe](https://github.com/dracut-ng/dracut/commit/96d153fe927987ce31a1f876b7eeea6fe9cee06a))
* **test:**
  *  run test 14 with systemd again ([43fa0c4e](https://github.com/dracut-ng/dracut/commit/43fa0c4e36c78566421092c63239985806a6610c))
  *  reenable extended tests for Arch ([130f4dfc](https://github.com/dracut-ng/dracut/commit/130f4dfce48b187944be9a0cacca794dd32428ad))
  *  tests needs more storage space ([96aa5073](https://github.com/dracut-ng/dracut/commit/96aa5073e38622fa431daec0c7237b71670de703))
  *  use --add instead of --modules to create test-makeroot ([51d06540](https://github.com/dracut-ng/dracut/commit/51d06540d19e4702ec61de6d2b5e2e68e8593b01))
  *  use `-cpu max` by default ([44f5359f](https://github.com/dracut-ng/dracut/commit/44f5359fe068d4c925777cf5291d8c64894bff4b))
* **test-root:**  quote _terminfodir variable ([db4ea5f3](https://github.com/dracut-ng/dracut/commit/db4ea5f3cf3850432db411fab084fbc831ed043f))
* **udev-rules:**  install all rules even if systemd is not installed ([df8bf213](https://github.com/dracut-ng/dracut/commit/df8bf213566ed1ac886775e2d6cb935119acbf20))
* **zipl:**
  *  quote zipl_env variable ([39b1ffa2](https://github.com/dracut-ng/dracut/commit/39b1ffa2ea05cb20371bb9fc3b1bd2d386d419d3))
  *  quote ID_FS_TYPE variable ([34da5799](https://github.com/dracut-ng/dracut/commit/34da5799512365513a4060fe41656d125d3db609))
* **znet:**  quote initdir variable ([79dbd435](https://github.com/dracut-ng/dracut/commit/79dbd435bc500000877765e13bea69a83724e8d2))

#### Performance

* **dracut-install:**
  *  use driver/module sysfs dirs for module name ([d71bec4a](https://github.com/dracut-ng/dracut/commit/d71bec4aa444d92820e428c0629d0e75e268c815))
  *  memoize find_kmod_module_from_sysfs_node ([6500e954](https://github.com/dracut-ng/dracut/commit/6500e95494175819b382acbac8eafcdf72fabd6d))
  *  preload kmod resources for quicker module lookup ([5a3f3773](https://github.com/dracut-ng/dracut/commit/5a3f377300ee38a573a5a29f534e926106805bb6))

#### Contributors

- Laszlo Gombos <laszlo.gombos@gmail.com>
- Benjamin Drung <benjamin.drung@canonical.com>
- BtbN <timo@rothenpieler.org>
- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- Brian C. Lane <bcl@redhat.com>
- Alper Nebi Yasak <alpernebiyasak@gmail.com>
- Cornelius Hoffmann <coding@hoffmn.de>
- Hector Martin <marcan@marcan.st>
- Jose Ignacio Tornos Martinez <jtornosm@redhat.com>
- Andrew Ammerlaan <andrewammerlaan@gentoo.org>
- Cameron Baird <cameronbaird@microsoft.com>
- Daniel McIlvaney <damcilva@microsoft.com>
- David Tardon <dtardon@redhat.com>
- Huaxin Lu <luhuaxin1@huawei.com>
- Ian Wienand <iwienand@redhat.com>
- Lidong Zhong <lidong.zhong@suse.com>
- Louis Sautier <sautier.louis@gmail.com>
- Paul Charlton <techguru@byiq.com>
- Pavel Valena <pvalena@redhat.com>
- Timo Rothenpieler <timo@rothenpieler.org>

dracut-102
=============

This release includes fixes for compatibility with the latest Linux kernel (v6.9), Linux firmware, and systemd (v256).

New dracut modules introduced by this release:
 - pcmcia: factor out pcmcia support into its own module
 - systemd-bsod: display a blue screen which contains a message relating to a boot failure
 - numlock: module to turn Num Lock on
 - systemd-cryptsetup: factor out systemd-cryptsetup support into its own module

dracut modules removed by this release:
 - dasd_rules: remove dasd handling consolidated in s390-tools
 - qeth_rules: remove qeth handling consolidated in 95znet
 - zfcp_rules: remove zfcp handling consolidated in s390-tools

The project builds test containers daily for the following Linux distributions:
 - Alpine
 - Arch
 - Debian (amd64 and arm64)
 - Fedora (amd64 and arm64)
 - Gentoo
 - openSUSE
 - Ubuntu
 - Void

These Linux distributions test dracut in various configurations (systemd/OpenRC/runit, glibc/musl, dhclient/NetworkManager/systemd-networkd).

#### Performance

* **crypt:**  move more rules to systemd-cryptsetup ([6325af42](https://github.com/dracut-ng/dracut/commit/6325af428d1436fff58b4c11a0ec6530df75114a))
* **dracut-init.sh:**  stop parsing args in dracut_instmods if --silent is found ([16863113](https://github.com/dracut-ng/dracut/commit/168631130cfe6b8993272d833f764c96377b526f))
* **dracut-systemd:**  check for systemd binary ([51d0257b](https://github.com/dracut-ng/dracut/commit/51d0257be63269d5018d284208d8148c8c7958dc))
* **drm:**  group dracut_instmods calls ([80f2caf4](https://github.com/dracut-ng/dracut/commit/80f2caf4f5ee47a708b5e4bd65c28e3f8ff1b9c8))
* **systemd:**
  *  remove duplicate rules ([d6ba849b](https://github.com/dracut-ng/dracut/commit/d6ba849bb6234ff11fe840ff5c7c327f7c8492f6))
  *  remove duplicate rules ([45a65df3](https://github.com/dracut-ng/dracut/commit/45a65df352f5460c74cc3af71562b62b1cb47429))
  *  remove duplicate rules ([db20908c](https://github.com/dracut-ng/dracut/commit/db20908cbbcf2779372e05d7d42162e83da86f12))
  *  remove duplicate rules ([fb75d4a8](https://github.com/dracut-ng/dracut/commit/fb75d4a862a04c235e46bf9a9d8ce918bcda0a9a))
  *  remove duplicate rules ([6c5520df](https://github.com/dracut-ng/dracut/commit/6c5520dff67a63df4ee735ab4f618d3faaf869d9))
* **systemd-udevd:**  remove duplicate rules ([28846382](https://github.com/dracut-ng/dracut/commit/28846382bf7d76b92cf6004345a982b4ae973f8a))

#### Bug Fixes

*   /etc/modprobe.d --> /run/modprobe.d ([424717af](https://github.com/dracut-ng/dracut/commit/424717af8e0a86dac7a9898bf161f04e35abd2c2))
*   crypt-gpg-lib.sh ([1ca38f04](https://github.com/dracut-ng/dracut/commit/1ca38f0476a7b0267a51f812b04f52de1453429e))
*   module-setup.sh missing stty ([1af35319](https://github.com/dracut-ng/dracut/commit/1af353193dbc4e5f23dc64746bbde4c0685c98b8))
*   network-manager should include kernel-network-modules ([cabd38d8](https://github.com/dracut-ng/dracut/commit/cabd38d8c375fafe13edc26c5ed908b60b44d8d3))
*   clean Makefile rule ([b89a0fb2](https://github.com/dracut-ng/dracut/commit/b89a0fb2b082b582289a6a8d46b9e0d200924d14))
* **01systemd-ldconfig:**  install ldconfig.real ([125bb0a8](https://github.com/dracut-ng/dracut/commit/125bb0a81e08d28f5c8a516a7e6cc8563de9fabb))
* **35-network-manager:**  let the kernel generate a UUID for /etc/machine-id ([1e2b5c30](https://github.com/dracut-ng/dracut/commit/1e2b5c305e79ac6998d4d59f64c6dee285214057))
* **90kernel-modules:**  add psmouse for some Fujitsu laptops ([343ce3bb](https://github.com/dracut-ng/dracut/commit/343ce3bbb947e4f7bb31542203b8fc68147f5add))
* **Dockerfile-Gentoo:**
  *  resolve glibc/libxcrypt conflict ([b6b8cf3e](https://github.com/dracut-ng/dracut/commit/b6b8cf3e1ca6e5964c02910695e22c296bcea458))
  *  pull in virtual/pkgconfig ([4d5e9079](https://github.com/dracut-ng/dracut/commit/4d5e90798f1b12343ad884dc53ecec846eaaa956))
  *  add --deep, --autounmask-continue, and depclean ([b182af73](https://github.com/dracut-ng/dracut/commit/b182af730c75732ab49aad545e95002ffb19c674))
* **base:**
  *  add support for rd.udev.log_level ([a471ca60](https://github.com/dracut-ng/dracut/commit/a471ca601b2ae6d924dab0603dbf275cb360a6ff))
  *  install /etc/udev/udev.conf in hostonly mode only ([2ab9ecce](https://github.com/dracut-ng/dracut/commit/2ab9eccee3352e8ce8a94842ff6ab496c6654166))
  *  log the full udev database in rdsosreport ([3fc15986](https://github.com/dracut-ng/dracut/commit/3fc15986518aea030a6a850ae779750110320276))
* **configure:**  resolve regression for crosscompiling ([25dabef1](https://github.com/dracut-ng/dracut/commit/25dabef1dab4612e31be84af3e262dc187ec4158))
* **cpio:**  eliminate compile time warning ([18788930](https://github.com/dracut-ng/dracut/commit/1878893054ec175ce2493cecf6ea81727519eceb))
* **crypt:**
  *  unlock encrypted devices by default during boot ([2339acfa](https://github.com/dracut-ng/dracut/commit/2339acfaeee60d6bb26a1103db2e53bc8f9cb2d1))
  *  add systemd-ask-password dependency if systemd is used ([caafea4e](https://github.com/dracut-ng/dracut/commit/caafea4e80305306d5aa8cd7540698a1932629dc))
* **dmsquash-live:**
  *  do not check ISO md5 if image filesystem ([c6906fea](https://github.com/dracut-ng/dracut/commit/c6906fea4df28428aa889c7bb8197689ae8107ee))
  *  use load_fstype to load driver for filesystems ([541ae946](https://github.com/dracut-ng/dracut/commit/541ae946b2fb715ed6d88b32dce97bd3ad30c599))
  *  update documentation ([d2d41a36](https://github.com/dracut-ng/dracut/commit/d2d41a36d86aca3deb05fe1be41bd06576c13d3f))
* **dracut:**
  *  microcode loading ([16573680](https://github.com/dracut-ng/dracut/commit/16573680d1b6cfba2147a41ab9c5309b7d91a71e))
  *  bsdcpio compatibility ([572afed1](https://github.com/dracut-ng/dracut/commit/572afed17595f45daab98670975aea78e81ff9b1))
  *  add support for RISC-V EFI ([136a9a10](https://github.com/dracut-ng/dracut/commit/136a9a101f142f24567bd345c8d3a388f8a75b32))
  *  move hooks directory from /usr/lib to /var/lib ([a45048b8](https://github.com/dracut-ng/dracut/commit/a45048b80c27ee5a45a380052a6d29ab1925f7f9), closes [#2588](https://github.com/dracut-ng/dracut/issues/2588))
* **dracut-fuctions.sh:**  correct wrong regex pattern for LVM dm devices ([4c2f756f](https://github.com/dracut-ng/dracut/commit/4c2f756f8fda68e6a89e47ca187695431d1baee0))
* **dracut-init.sh:**
  *  force to perform the actual action ([ffeb32b2](https://github.com/dracut-ng/dracut/commit/ffeb32b2d2caecc2111bfd93b6919dc4f09d3c2d))
  *  handle decompress with `--sysroot` ([91cdd57f](https://github.com/dracut-ng/dracut/commit/91cdd57f519f90c5c31741616f90c262cf90700c))
* **dracut-install:**
  *  release memory allocated for regular expressions ([d93bac05](https://github.com/dracut-ng/dracut/commit/d93bac05471b82bb38b94af6fa81ef0337e9e2c9))
  *  continue parsing if ldd prints "cannot be preloaded" ([ace9e1b5](https://github.com/dracut-ng/dracut/commit/ace9e1b58c09e1e91621ad2219f7a96b7edbbd38))
* **dracut-lib:**  only remove initqueue/finished scripts, not the hook dir ([e8257deb](https://github.com/dracut-ng/dracut/commit/e8257debcd42c7640ad0e3b9ab4c5306794776ec), closes [#2620](https://github.com/dracut-ng/dracut/issues/2620))
* **dracut-systemd:**
  *  include systemd-ask-password module ([0bfe0867](https://github.com/dracut-ng/dracut/commit/0bfe0867dae9f60ec316f4b90bd0b3ea9f2a027c))
  *  replace `rd.udev.log-priority` with `rd.udev.log_level` ([c1275d87](https://github.com/dracut-ng/dracut/commit/c1275d878cc6f6dac5b59a2024e6b5cc777dd6c7))
* **dracut.sh:**
  *  include efi mountpoint for hostonly ([4a6a4ac6](https://github.com/dracut-ng/dracut/commit/4a6a4ac6a92dbbcd6edeb3ca4d9148d90ac3423d))
  *  don't unset LD_PRELOAD ([1eff6933](https://github.com/dracut-ng/dracut/commit/1eff6933fb3a38cd03ac64785dc62afbc8e5b480))
  *  do not add device if find_block_device fails ([0f6c46aa](https://github.com/dracut-ng/dracut/commit/0f6c46aa66a1dc9582d3ec5e18ed56b55e970ce8))
  *  make uki's reproducible ([aabb5a41](https://github.com/dracut-ng/dracut/commit/aabb5a4106295c6d3234215ab30f8dc2fb93eed7))
  *  omit compressed kernel modules from find searching exec files ([ad36b61e](https://github.com/dracut-ng/dracut/commit/ad36b61ec1a26714fbe3049435eff7199ffea5e0))
* **fips:**  remove /dev/{random,urandom} pre-creation ([5beda2ea](https://github.com/dracut-ng/dracut/commit/5beda2ea009046c1398ea5af868cc5743beb0f01))
* **github:**  add the recently introduced modules to the labeler ([5957f5c5](https://github.com/dracut-ng/dracut/commit/5957f5c5950fa6415369ce91fdc362710e7689a6))
* **i18n:**  handle keymap includes with `--sysroot` ([5b714d25](https://github.com/dracut-ng/dracut/commit/5b714d25e1750132429005d289c81522aa2ae8d5))
* **install.d:**
  *  prevent failure when kernel-install command is not `add` ([6fec7d39](https://github.com/dracut-ng/dracut/commit/6fec7d3936d25bbfb15ee7362fd0a9499644bc32))
  *  correctly install pre-genned image and die if no args ([8388ad14](https://github.com/dracut-ng/dracut/commit/8388ad149c698c951089606352fdb0cdcaaf40c9))
  *  simplify and use what kernel-install gives us ([d4015538](https://github.com/dracut-ng/dracut/commit/d40155385d060f8d8608fa8a4931e2e42ddc3a8f))
* **iscsi:**  do not add host's runtime iscsi configure files in initrd ([292e79e8](https://github.com/dracut-ng/dracut/commit/292e79e88c6c6a53af33abe840b1571879001ba6))
* **man:**  further clarify live-image overlay types & RAM usage ([5fa405dd](https://github.com/dracut-ng/dracut/commit/5fa405dd1f705f035ba91350a2b0799ddbd87893))
* **memstrack:**  move the console warning to be a comment ([ee1c37e3](https://github.com/dracut-ng/dracut/commit/ee1c37e31e5d14f35cfab3353547ee1177d1c9e0))
* **multipath:**  explicitly check if `hostonly_cmdline` is `yes` ([c262ec6d](https://github.com/dracut-ng/dracut/commit/c262ec6d1c065b3c0b00ce864f2ea7c849d13b9d))
* **numlock:**
  *  use the same shebang as other dracut modules ([67987959](https://github.com/dracut-ng/dracut/commit/679879590f4cb428e79c1a28a8b77357dd6bae1a))
  *  use the same shebang as other dracut modules ([efa02688](https://github.com/dracut-ng/dracut/commit/efa0268881df36824c72020e6f8b8966cc189375))
* **nvmf:**  move /etc/nvme/host{nqn,id} requirement to hostonly ([54cd6479](https://github.com/dracut-ng/dracut/commit/54cd647932c42e5520a8bcdd3e5882210e4603c5))
* **release:**  dracut --> dracut-ng for NEWS.md ([6fb8fc8b](https://github.com/dracut-ng/dracut/commit/6fb8fc8b70d20b82bfcda99d9da193e16d5f315b))
* **systemd:**  explicitly install some libs that will not be statically included ([04b362d7](https://github.com/dracut-ng/dracut/commit/04b362d713235459cff1f370efb4cd5e36e4a358), closes [#2642](https://github.com/dracut-ng/dracut/issues/2642))
* **systemd-ask-password:**
  *  no graphical output in aarch64 ([4cc962aa](https://github.com/dracut-ng/dracut/commit/4cc962aa0989c53822f4bd6c5431488c7707124e))
  *  resolve regression ([25c5cfa2](https://github.com/dracut-ng/dracut/commit/25c5cfa2ca70a4b76fafa7a12ebb87b51256adba))
* **systemd-cryptsetup:**  add potentially needed modules to generic initrd ([9179ade8](https://github.com/dracut-ng/dracut/commit/9179ade8a0e33a0c6ef951073f3b89790ee5eda0))
* **systemd-initrd:**
  *  systemd based initrd needs journald and tmpfiles ([860b35c3](https://github.com/dracut-ng/dracut/commit/860b35c38ea8764e75aed3d5fca8b811b026f2a6))
  *  only included if another module depends on it ([6d3e69ac](https://github.com/dracut-ng/dracut/commit/6d3e69ac40afd2e4b61b2fc244671a417ea8b03d))
  *  add systemd-udevd dependency ([8910f8bb](https://github.com/dracut-ng/dracut/commit/8910f8bbeaedf2b55c788490080290be4a122114))
* **systemd-journald:**  add systemd dependency ([06e4a854](https://github.com/dracut-ng/dracut/commit/06e4a854700e6353771aa8c13379f4f541dc53ee))
* **systemd-networkd:**
  *  drop networkctl as it has a dependency on dbus ([7a1519bf](https://github.com/dracut-ng/dracut/commit/7a1519bfc6bd96691e7df2c6a655f9fd1a0b5e77))
  *  dbus is not a mandatory dependency ([6f764a1d](https://github.com/dracut-ng/dracut/commit/6f764a1db8a40fe484682c38ef649abc333150c5))
* **systemd-sysext:**  handle confexts and correct extensions search path ([30da2173](https://github.com/dracut-ng/dracut/commit/30da2173e25cf445d52e30456f6938230efd97b1))
* **systemd-udevd:**  add systemd-sysctl dependency ([2c866733](https://github.com/dracut-ng/dracut/commit/2c866733bff45c8cba4efdc3fae26eb98ac9f546))
* **test:**
  *  add support for thin volumes in the Gentoo container ([6fc87f5c](https://github.com/dracut-ng/dracut/commit/6fc87f5c664788d1715cca49d1b327611625144f))
  *  fixup Gentoo CI ([8bcd077d](https://github.com/dracut-ng/dracut/commit/8bcd077d5eb5a811cb34b0d307a5d886ecddca60))
  *  remove ib700wdt kernel module from tests ([2526a92e](https://github.com/dracut-ng/dracut/commit/2526a92e9867e1800875b9889de5739c8930381d))
  *  do not omit dracut modules for initramfs.testing ([5cb42481](https://github.com/dracut-ng/dracut/commit/5cb42481e8738b6a173e0ecacdf722b772188336))
  *  fixup Gentoo CI ([3b9054a4](https://github.com/dracut-ng/dracut/commit/3b9054a404bdf15ab92a35d7b8d58841d31c905e))
* **znet:**  append to udev rules so each rd.znet_ifname is effective ([22f51730](https://github.com/dracut-ng/dracut/commit/22f51730860a1715c9420d066aea691bfa03a81e))

#### Features

* **90dm:**  close crypt devices using cryptsetup ([fba8622f](https://github.com/dracut-ng/dracut/commit/fba8622fdd06540bd2a62262e945fe66392a26d3), closes [#204](https://github.com/dracut-ng/dracut/issues/204))
* **90systemd-cryptsetup:**  socket key files ([80480a73](https://github.com/dracut-ng/dracut/commit/80480a731aabec11a1e72f08725a47c63c45632d))
* **dasd:**  minimize dasd handling consolidated in s390-tools ([36e1f884](https://github.com/dracut-ng/dracut/commit/36e1f88417557d5b031a490dfc810a3c9d7d5f64))
* **dasd_mod:**  minimize dasd handling consolidated in s390-tools ([2397c479](https://github.com/dracut-ng/dracut/commit/2397c4797a426b7dd936e6ea1910c647f38461b5))
* **dasd_rules:**  remove dasd handling consolidated in s390-tools ([72c945ca](https://github.com/dracut-ng/dracut/commit/72c945cad0961312cecbba62fcf2df8972909230))
* **dracut.sh:**  make initramfs-${kernel}.img filename configurable ([28820e20](https://github.com/dracut-ng/dracut/commit/28820e20532890b9b0cf816ce1b527c582a1f3b3))
* **ifcfg:**  minimize s390-specific network configuration aspects ([457e66e6](https://github.com/dracut-ng/dracut/commit/457e66e679b780ec4de58b87237f29eeed548e08))
* **lsinitrd.sh:**
  *  print stored dracut cmdline ([d10455ad](https://github.com/dracut-ng/dracut/commit/d10455ad1a0d4c3f2c00f5ec7aabace8487aee6d))
  *  enable unpacking files from squash-root.img ([9b12ef98](https://github.com/dracut-ng/dracut/commit/9b12ef98a8fdf2b8611fe82f96560c690bb5d2ad))
* **numlock:**  add module to turn Num Lock on ([60b44261](https://github.com/dracut-ng/dracut/commit/60b442614de207bb7107743ec15261b17b550c41))
* **pcmcia:**  factor out pcmcia support into its own module ([4b21d5f7](https://github.com/dracut-ng/dracut/commit/4b21d5f740b9f0ae5c8843713543ae62ec42b225))
* **qeth_rules:**  remove qeth handling consolidated in 95znet ([198a86c2](https://github.com/dracut-ng/dracut/commit/198a86c2c7fdd39446d785afa1917ccb4727809d))
* **systemd-bsod:**  dracut module for systemd-bsod ([d7ab919e](https://github.com/dracut-ng/dracut/commit/d7ab919eaa6d820545ca73549e1ce87f8c00aefb))
* **systemd-cryptsetup:**  new module for systemd-cryptsetup ([649e37bc](https://github.com/dracut-ng/dracut/commit/649e37bcd5ac46d5ac440b80297370c07ee7e1a8))
* **systemd-pcrphase:**  include systemd-pcrphase if dependencies are met ([c5cbdaf3](https://github.com/dracut-ng/dracut/commit/c5cbdaf3050f46c446fe736032ae872376f6d365))
* **tpm2-tss:**  add tpm2.target and systemd-tpm2-generator ([edd870ed](https://github.com/dracut-ng/dracut/commit/edd870eda138bb9fe617f3e71b524dcf7d631e65))
* **zfcp:**  minimize zfcp handling consolidated in s390-tools ([7745a81a](https://github.com/dracut-ng/dracut/commit/7745a81afd85a437d4ec9bf023efa942cd5ca109))
* **zfcp_rules:**  remove zfcp handling consolidated in s390-tools ([b5a35f9d](https://github.com/dracut-ng/dracut/commit/b5a35f9d9bad1958e9c5433d8e2b167d4bb83195))
* **znet:**  use zdev for consolidated device configuration ([658a21ac](https://github.com/dracut-ng/dracut/commit/658a21ac276b8d7aba950c5ad7c3f8132681512b))

#### Contributors

- Laszlo Gombos <laszlo.gombos@gmail.com>
- Steffen Maier <maier@linux.ibm.com>
- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- Andrew Ammerlaan <andrewammerlaan@gentoo.org>
- Daniel Winzen <daniel@danwin1210.de>
- Federico Vaga <federico.vaga@cern.ch>
- Kamil Szczęk <kamil@szczek.dev>
- dalto8 <57767042+dalto8@users.noreply.github.com>
- farfalleflickan <6597735+farfalleflickan@users.noreply.github.com>
- Andrew Gunnerson <accounts+github@chiller3.com>
- Anton Lundin <glance@ac2.se>
- Bernhard Rosenkraenzer <bero@lindev.ch>
- Frederick Grose <4335897+FGrose@users.noreply.github.com>
- Manuel Fombuena <fombuena@outlook.com>
- Nick Rosbrook <enr0n@ubuntu.com>
- Reilly Brogan <reilly@reillybrogan.com>
- Thierry Bultel <thierry.bultel@linatsea.fr>
- Tomas Bzatek <tbzatek@redhat.com>
- Tomasz Paweł Gajc <tpgxyz@gmail.com>
- Valentin David <valentin.david@canonical.com>
- Vitaly Kuznetsov <vkuznets@redhat.com>
- Wenchao Hao <haowenchao@huawei.com>

dracut-101
=============

#### Bug Fixes

Release 101 resolves a regression introduced by release 100 - https://github.com/dracut-ng/dracut/issues/130 .

* **dracut.sh:**  revert: "do not add device if find_block_device returns" ([0885d6b2](https://github.com/dracut-ng/dracut/commit/0885d6b2bb9d449f8a4e4f89ded3b619338df28d))
* **dmsquash-live:**  update documentation ([d2d41a36](https://github.com/dracut-ng/dracut/commit/d2d41a36d86aca3deb05fe1be41bd06576c13d3f))
* **dracut-install:**  continue parsing if ldd prints "cannot be preloaded" ([ace9e1b5](https://github.com/dracut-ng/dracut/commit/ace9e1b58c09e1e91621ad2219f7a96b7edbbd38))
* **dracut-systemd:**  replace `rd.udev.log-priority` with `rd.udev.log_level` ([c1275d87](https://github.com/dracut-ng/dracut/commit/c1275d878cc6f6dac5b59a2024e6b5cc777dd6c7))
* **dracut.sh:**  omit compressed kernel modules from find searching exec files ([ad36b61e](https://github.com/dracut-ng/dracut/commit/ad36b61ec1a26714fbe3049435eff7199ffea5e0))
*   improve Gentoo container ([76963537](https://github.com/dracut-ng/dracut/commit/76963537edcfbad21c5fa096834e982564653808))

#### Contributors

- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- Laszlo Gombos <laszlo.gombos@gmail.com>

dracut-100
=============

Release 100 of [dracut](https://github.com/dracut-ng/dracut) serves as a drop-in replacement for the original [dracut](https://github.com/dracutdevs/dracut) repository.
This release marks a significant milestone in our commitment to providing an alternative, community-driven solution for creating an initramfs image.
The original dracut project is no longer actively maintained (its last tagged release dates back to 2022).
Forking allows the community to take ownership of the project and address maintenance issues independently.

This release includes fixes for compatibility with the latest Linux kernel (v6.8), Linux firmware, and systemd (v255).

A new dracut module named net-lib has been added to enhance networking support.

Support for new Linux kernel modules have been added to support new devices, including the Surface Laptop 4 and MacBook Pro.

The project builds test containers daily for the following Linux distributions: Arch Linux, Debian, Fedora, Gentoo, openSUSE, and Ubuntu, in various configurations (systemd, OpenRC, glibc, musl).
All enabled integration tests have passed at the time of this release.

#### Bug Fixes

*   wait 12 hours before halt on media check fail ([faa3db78](https://github.com/dracut-ng/dracut/commit/faa3db78b58554710e81ef95cceab68a1d52311e))
*   do not use modprobe --all ([5850486f](https://github.com/dracut-ng/dracut/commit/5850486fbc3e7d6550fadf21d8e060c236214e9f))
* **45ifcfg:**  mark as deprecated and strictly opt-in ([79e1def5](https://github.com/dracut-ng/dracut/commit/79e1def5ab9a19fdb9a5cc33c4893e49a7a10b67))
* **90kernel-modules:**
  *  add surface_aggregator_registry for Surface Laptop 4 ([8cc89664](https://github.com/dracut-ng/dracut/commit/8cc8966491830072f75a918c51533bea11211253))
  *  add intel_lpss_pci for MacBook Pro 2017 ([f0526fde](https://github.com/dracut-ng/dracut/commit/f0526fdea993d7e1ffa612c93656c77b41eb0509))
* **90multipath:**  drop unneeded dependencies from configure service ([9ac195c1](https://github.com/dracut-ng/dracut/commit/9ac195c11c1f38dc6f0389d99fb3e76509c2e1c4))
* **Makefile:**  release is now just made out of a git sha ([71109aed](https://github.com/dracut-ng/dracut/commit/71109aed43420eaba7e2168ae7b8d48c8a1078de))
* **TEST-62-SKIPCPIO:**  test always skipped due to buggy `test_check` ([5b5d395a](https://github.com/dracut-ng/dracut/commit/5b5d395a6b4d9118c077102b5bbd74748e601a4e))
* **base:**  correct handling of quiet in loginit ([49b9c219](https://github.com/dracut-ng/dracut/commit/49b9c2196a6a282cdb9c24738b2ab27d9a67134c))
* **caps:**  return 1 if binary requirements are not met ([243be951](https://github.com/dracut-ng/dracut/commit/243be951958b9111c50b98eae399f610a5a07a99))
* **check_live_ram:**  increase /run tmpfs size, if needed ([e12ad733](https://github.com/dracut-ng/dracut/commit/e12ad7330f9db547014eeeec37aeab779461bc30))
* **configure:**  misleading error if C compiler is not installed ([4980bad3](https://github.com/dracut-ng/dracut/commit/4980bad34775da715a2639b736cba5e65a8a2604))
* **dmsquash-live:**
  *  use the overlay size with thin provisioning ([2e025eb2](https://github.com/dracut-ng/dracut/commit/2e025eb2105d8f8c67b07b0140915566873e12f0))
  *  handle relative pathspec ([0c6d257f](https://github.com/dracut-ng/dracut/commit/0c6d257f9c7d62eb449d71789f4f68414ba97aa2))
* **dracut:**  correct regression with multiple `rd.break=` options ([3d727a7d](https://github.com/dracut-ng/dracut/commit/3d727a7d92cc916634369c8fa5fd97b4444d5aa7))
* **dracut-init.sh:**  do not print by default if a modules is not installed ([d73cc24e](https://github.com/dracut-ng/dracut/commit/d73cc24e112c01aa701a96a7b8a58adce78409e7))
* **dracut-initramfs-restore.sh:**  do not set selinux labels if disabled ([4d594210](https://github.com/dracut-ng/dracut/commit/4d594210d6ef4f04a9dbadacea73e9461ded352d))
* **dracut-install:**  file created without restricting permissions ([3439d139](https://github.com/dracut-ng/dracut/commit/3439d139616196f0cd0af2e6244acf6c5f85621f))
* **dracut-lib:**  use poweroff instead of halt ([0ca14da6](https://github.com/dracut-ng/dracut/commit/0ca14da655b688f29e4c05d98d9e2c2f63bdf59b))
* **dracut-systemd:**  use `DRACUT_VERSION` instead of `VERSION` ([a2c64222](https://github.com/dracut-ng/dracut/commit/a2c64222cfba73a36dbb87e970e71e717e7cafb0))
* **dracut-util:**  do not call `strcmp` if the `value` argument is NULL ([b5fb6e04](https://github.com/dracut-ng/dracut/commit/b5fb6e049e1fcb465f9371cefeedcfecce7a8d53))
* **dracut.sh:**
  *  recognize kernel file in /boot named vmlinux too ([f2dfc257](https://github.com/dracut-ng/dracut/commit/f2dfc2576dc66ec27ee1b8fde7c129622e8373aa))
  *  do not add device if `find_block_device` returns an error ([18abcc53](https://github.com/dracut-ng/dracut/commit/18abcc53df27be26d312cefc416bae9d97c6860a), closes [#2592](https://github.com/dracut-ng/dracut/issues/2592))
  *  skip README for AMD microcode generation ([9df35524](https://github.com/dracut-ng/dracut/commit/9df355243c26ec7079e51eef15768fe21a8afdca), closes [#2541](https://github.com/dracut-ng/dracut/issues/2541))
* **github:**  update format of labeler ([de8ac630](https://github.com/dracut-ng/dracut/commit/de8ac6300d115a05d467dbb6b9a7c2599a2d306f))
* **i18n:**
  *  silence spurious setfont stderr warning ([27f31c03](https://github.com/dracut-ng/dracut/commit/27f31c037d97433698232976274e2acfac91523e))
  *  handle symlinked keymap ([1f73bc8b](https://github.com/dracut-ng/dracut/commit/1f73bc8b5bf4f19a805c2fefecf3e8bd2b59b17d))
* **install:**  handle new -Walloc-size for GCC 14 ([23b9ec22](https://github.com/dracut-ng/dracut/commit/23b9ec22503fee6b3a3590c5753c086e1fb94910))
* **livenet:**
  *  split `imgsize` calculation to avoid misleading error message ([4649b4c6](https://github.com/dracut-ng/dracut/commit/4649b4c673cd74258e4ed9a1c3c6c553d9d02e44))
  *  check also `content-length` from live image header ([6289d5f4](https://github.com/dracut-ng/dracut/commit/6289d5f4348a291f70d8fc105de2fa2c1b5291f4))
  *  propagate error code ([61a00cf8](https://github.com/dracut-ng/dracut/commit/61a00cf8fec39e931a81f6ff0af4dfd62e308646))
* **man:**  rd.break parameter can be specified multiple times ([5a99e671](https://github.com/dracut-ng/dracut/commit/5a99e671f6d81de75bec71f1832444137559957d))
* **net-lib:**  add a new dracut module called net-lib ([5e1fec16](https://github.com/dracut-ng/dracut/commit/5e1fec1688a6b1cbcb4bea27a77710ae60c0d2f1))
* **overlayfs:**
  *  to allow overlay on top of network device (nfs) ([bedde0f1](https://github.com/dracut-ng/dracut/commit/bedde0f15708303f9907ed8a0d9e217c98e3bf07))
  *  allow hostonly ([929e3160](https://github.com/dracut-ng/dracut/commit/929e3160102761a2e0a471d0a5cf0a0ac7ac663d))
  *  split overlayfs mount in two steps ([bddffeda](https://github.com/dracut-ng/dracut/commit/bddffedae038ceca263a904e40513a6e92f1b558))
* **pcsc:**
  *  add --disable-polkit to pcscd.service ([2689123c](https://github.com/dracut-ng/dracut/commit/2689123c55bd2b43e7e2dba3e6bb93621a541916))
  *  add opensc load module file ([882e9335](https://github.com/dracut-ng/dracut/commit/882e9335934a86f88ba3b0cb7800a0d2c004b6a2))
* **pkcs11:**  delete trailing dot on libcryptsetup-token-systemd-pkcs11.so ([1c762c0d](https://github.com/dracut-ng/dracut/commit/1c762c0da6ed2bb6fa44d5e0968605cc4d45361c))
* **plymouth:**  return 1 if binary requirements are not met ([edb14009](https://github.com/dracut-ng/dracut/commit/edb140094e7144834c9d53652fbacdfb3053ab72))
* **release:**
  *  maintain dracut.html in the source tree ([7b05aa8b](https://github.com/dracut-ng/dracut/commit/7b05aa8b9eee5d665bfd010950bf01ee03e0fb12))
  *  dracutdevs/dracut --> dracut-ng/dracut ([8906474b](https://github.com/dracut-ng/dracut/commit/8906474b4116190f45b5871079a826934e51f2e6))
* **resume:**
  *  include in hostonly mode if resume= on cmdline ([d2ff89e2](https://github.com/dracut-ng/dracut/commit/d2ff89e24479f1b8c2a21613632a4beb58c2a182))
  *  add new systemd-hibernate-resume.service ([b73b5e0f](https://github.com/dracut-ng/dracut/commit/b73b5e0fc94355efcff908ac1779fb187216484e), closes [#2513](https://github.com/dracut-ng/dracut/issues/2513))
* **rootfs-block:**  remove support for [no]readonlyroot and fastboot ([469935fc](https://github.com/dracut-ng/dracut/commit/469935fcca330c215009937eedbfb0dc15d533be))
* **systemd-255:**  handle systemd-pcr{phase -> extend} rename ([b63e90ab](https://github.com/dracut-ng/dracut/commit/b63e90ab4e34b35ba0ce009992b0fc019eca3761))
* **systemd-journald:**  add systemd-sysusers dependency ([4971f443](https://github.com/dracut-ng/dracut/commit/4971f443726360216a4ef3ba8baea258a1cd0f3b))
* **systemd-repart:**  correct undefined $libdir ([1586af09](https://github.com/dracut-ng/dracut/commit/1586af098fb17f7565d1699953e4e4b536304089))
* **test:**  running tests no longer requires to be root ([3dad8237](https://github.com/dracut-ng/dracut/commit/3dad82379aaa0afc05dbe717b1ab958ac7e9cf23))
* **udev-rules:**  remove legacy persistent network device name rule ([898ce135](https://github.com/dracut-ng/dracut/commit/898ce1359ccd54fdb366749127f825dc384d9efa))
* **zfcp_rules:**  correct shellcheck regression when parsing ccw args ([5d2bda46](https://github.com/dracut-ng/dracut/commit/5d2bda46f4e75e85445ee4d3bd3f68bf966287b9))

#### Features

* **dracut.sh:**  protect `push_host_devs` function ([7b54d2fb](https://github.com/dracut-ng/dracut/commit/7b54d2fbbfb02c0f4e3d27dc76fb6679f6f31cd4))
* **kernel-modules:**
  *  Install SPMI modules on ARM/RISC-V ([9491c285](https://github.com/dracut-ng/dracut/commit/9491c2852501fab5d0000a095706ac6469cbfdf1))
  *  add Qualcomm IPC router to enable USB ([dd9a4bc1](https://github.com/dracut-ng/dracut/commit/dd9a4bc1b13a0cc8abac980bc3cceffb67111e64))
* **network:**  include 98-default-mac-none.link if it exists ([b7f09500](https://github.com/dracut-ng/dracut/commit/b7f0950097b19092434836ad6708187d5d0351bd))

#### Contributors

- Laszlo Gombos <laszlo.gombos@gmail.com>
- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- Benjamin Drung <benjamin.drung@canonical.com>
- Henrik Gombos <henrik99999@gmail.com>
- Jan Macku <jamacku@redhat.com>
- Manuel Fombuena <mfombuena@innovara.co.uk>
- Sam James <sam@gentoo.org>
- Adam Williamson <awilliam@redhat.com>
- Andrew Ammerlaan <andrewammerlaan@gentoo.org>
- Benjamin Marzinski <bmarzins@redhat.com>
- Bernhard M. Wiedemann <bwiedemann@suse.de>
- Brian Harring <ferringb@gmail.com>
- Daniel P. Berrangé <berrange@redhat.com>
- David Cassany <dcassany@suse.com>
- Dusty Mabe <dusty@dustymabe.com>
- Frederick Grose <fgrose@sugarlabs.org>
- Icenowy Zheng <uwu@icenowy.me>
- Ihno Krumreich <ihno@suse.com>
- Jeremy Linton <jeremy.linton@arm.com>
- Jonathan Lebon <jonathan@jlebon.com>
- Lukas Nykryn <lnykryn@redhat.com>
- Neal Gompa <neal@gompa.dev>
- Thomas Blume <thomas.blume@suse.com>
- gregory-lee-bartholomew <gregory.lee.bartholomew@gmail.com>
- innovara <fombuena@outlook.com>

dracut-060
==========

#### Performance

* **dracut-install:**
  *  don't strdup() environment block ([efd4ca27](https://github.com/dracutdevs/dracut/commit/efd4ca271f15530d7264d2c87a104284e20b28aa))
  *  don't reallocate {src,dst}path in hmac_install() ([77226cb4](https://github.com/dracutdevs/dracut/commit/77226cb412822dc7614037c6d9225d98e64d4a55))
  *  don't strdup() excessively for dracut_install() ([a20556f0](https://github.com/dracutdevs/dracut/commit/a20556f0e51249e501aeb87eb5a337a15db52253))
  *  stat() w/unused buf -> access(F_OK) in dracut-install ([e7ed8337](https://github.com/dracutdevs/dracut/commit/e7ed8337bb9fec0283af5dc745450394ba649a03))
  *  multiple single-character strstr()s -> strpbrk() ([751a110f](https://github.com/dracutdevs/dracut/commit/751a110f29f07cb41246c09784c63bb26bb708c6))

#### Bug Fixes

*   codespell ([ddf63231](https://github.com/dracutdevs/dracut/commit/ddf6323145d50d33a897687474c73770328bf757))
*   make iso-scan trigger udev events ([7b530f26](https://github.com/dracutdevs/dracut/commit/7b530f26368d723dcc34fb67d687c60009b06412), closes [#2183](https://github.com/dracutdevs/dracut/issues/2183))
*   shellcheck 0.8.0 ([88fe9205](https://github.com/dracutdevs/dracut/commit/88fe9205de49c12ed8eaac2ca227a72830750955))
*   shellcheck 0.8.0 ([08b63a25](https://github.com/dracutdevs/dracut/commit/08b63a25296d689186c6343f96e764bf893367cb))
* **99base:**  adjust to allow mksh as initrd shell ([a0d14d3b](https://github.com/dracutdevs/dracut/commit/a0d14d3bc691b318507c01708bc67d9e3b9d5109))
* **Makefile:**
  *  remove leftover rpm build rules ([f5cc202e](https://github.com/dracutdevs/dracut/commit/f5cc202e998eb22bda98920b8eeeb0f027ca0b6e))
  *  no longer upload to kernel.org ([ffc766d2](https://github.com/dracutdevs/dracut/commit/ffc766d23d9175673f722a3c81e7609496167845))
  *  execute command -v instead of which ([4235c035](https://github.com/dracutdevs/dracut/commit/4235c035ff1abad0c22125c26cab813c42b29da0))
* **base:**  do not quote $CLINE in the `set` command ([8b951d20](https://github.com/dracutdevs/dracut/commit/8b951d20d409b3647c85a9c6d064ccb15cdb5fe7))
* **bluetooth:**
  *  make bluetooth rules more strict ([dfa408c9](https://github.com/dracutdevs/dracut/commit/dfa408c9de7cd0b0af6099b6f1e0cce2e70ec467))
  *  add missing files ([e84d65c5](https://github.com/dracutdevs/dracut/commit/e84d65c5b0191582e26fe9cc150d460652b34b33))
  *  include it if Appearance matches the value assigned for keyboard ([8079ceaf](https://github.com/dracutdevs/dracut/commit/8079ceafcac910d0c061830769866710c3e889a8))
  *  warn user instead of including it by default ([0ecb0388](https://github.com/dracutdevs/dracut/commit/0ecb038832038523a27f989d0eb82b45fb67861c))
* **btrfs:**
  *  do not require module via cmdline when --no-kernel ([7ed765dd](https://github.com/dracutdevs/dracut/commit/7ed765dd23e4c5616c82d1cbf8b4dbceaafc7647))
  *  add missing cmdline function ([2b47a2ef](https://github.com/dracutdevs/dracut/commit/2b47a2efe91ab8be480925c04388200a3666812c))
* **crypt:**  add missing libraries ([c5dca3d6](https://github.com/dracutdevs/dracut/commit/c5dca3d68915cef077fda2bc5292e12f82cf6dd6))
* **crypt-gpg:**  do not use always --card-status ([e3e8108e](https://github.com/dracutdevs/dracut/commit/e3e8108eb75247249ec05eaba943c3f48637c04b))
* **dmsquash-live:**
  *  allow other fstypes ([4000a1ec](https://github.com/dracutdevs/dracut/commit/4000a1ecff208479254be8ce88de826099e2b685))
  *  restore compatibility with earlier releases ([0e780720](https://github.com/dracutdevs/dracut/commit/0e780720efe6488c4e07af39926575ee12f40339))
  *  live:/dev/* ([93339444](https://github.com/dracutdevs/dracut/commit/93339444361303c15e26b6ff5cea6ef99ad0b3e0))
* **dmsquash-live-autooverlay:**  specify filesystemtype when it is already known ([179e1a99](https://github.com/dracutdevs/dracut/commit/179e1a992fc2b74d55a600bef152d5df43802104))
* **dracut-functions:**  avoid calling grep with PCRE (-P) ([67591e88](https://github.com/dracutdevs/dracut/commit/67591e8855006eb02aa0ffab7349ab770e471473))
* **dracut-functions.sh:**  convert mmcblk to the real kernel module name ([a62e895d](https://github.com/dracutdevs/dracut/commit/a62e895db9510f0fc4c47ee81b1436096eca4d64))
* **dracut-init.sh:**
  *  `module_check` method ignores `forced` option ([6c9f403f](https://github.com/dracutdevs/dracut/commit/6c9f403f1c219b8e2ff62011bfcc1b5e254b411a))
  *  use the local _ret variable ([1b53bb62](https://github.com/dracutdevs/dracut/commit/1b53bb6297d83940b52e806c01030e8f5035d9f2))
  *  correct check in `is_qemu_virtualized` function ([3e2f685e](https://github.com/dracutdevs/dracut/commit/3e2f685ecb4a968d5cd889803d5a248dab89473a))
  *  correct typo in comment ([1aafcab9](https://github.com/dracutdevs/dracut/commit/1aafcab935b7e84cea8fc3f084b6935f87b2b8a5))
* **dracut-initramfs-restore.sh:**  handle /etc/machine-id empty or uninitialized ([260883d9](https://github.com/dracutdevs/dracut/commit/260883d96f33e7aced3d00c85d0ebffcec1385a1))
* **dracut-install:**
  *  protect against broken links pointing to themselves ([32f6f364](https://github.com/dracutdevs/dracut/commit/32f6f364ddeb706bf8741f2895d60022aee264e7))
  *  prevent possible infinite recursion with suppliers ([131822e2](https://github.com/dracutdevs/dracut/commit/131822e26d76a3ce2028e9a545be2af066805629))
  *  continue parsing if ldd prints "cannot execute binary file" ([9a531ca0](https://github.com/dracutdevs/dracut/commit/9a531ca044e3cfe9b670e7e4d59a7bae5bafec1e))
* **dracut-lib.sh:**  remove successful finished initqueue scripts ([07af8d58](https://github.com/dracutdevs/dracut/commit/07af8d58745a121052cab49c70a476f02996da1e))
* **dracut-systemd:**
  *  rootfs-generator cannot write outside of generator dir ([86c8a5a7](https://github.com/dracutdevs/dracut/commit/86c8a5a7c2573645e67537fb9975efab808d42c9))
  *  check and create generator dir outside of inner function ([acfa793b](https://github.com/dracutdevs/dracut/commit/acfa793b5cc035ebd36b0c5ce97ba2fd89e5745c))
  *  do not hardcode the systemd generator directory ([a7c04716](https://github.com/dracutdevs/dracut/commit/a7c04716a5e528d86135bf87745054f7cbd54469))
  *  remove unused argument ([eb75861c](https://github.com/dracutdevs/dracut/commit/eb75861c2a1c05eb142616da1891a7fa5a2a34e1))
* **dracut.sh:**
  *  remove microcode check based on CONFIG_MICROCODE_[AMD|INTEL] ([6c80408c](https://github.com/dracutdevs/dracut/commit/6c80408c8644a0add1907b0593eb83f90d6247b1))
  *  exit if resolving executable dependencies fails ([b2c6b584](https://github.com/dracutdevs/dracut/commit/b2c6b584e2227e68f54c8843925dcb73aefe87ac))
  *  shellcheck warning SC1004 ([dbdab2d8](https://github.com/dracutdevs/dracut/commit/dbdab2d87fa49c7fdd08b274d8a21e6046360cad))
  *  use gawk for strtonum ([33a66ed0](https://github.com/dracutdevs/dracut/commit/33a66ed04bdc30eccb172a0cd6dcc36d9d74f825))
  *  also prevent fsfreeze for tmpfs ([09d3ec16](https://github.com/dracutdevs/dracut/commit/09d3ec1648822d84e95b274b60cb51b80e8f49f9))
  *  correct path for UEFI stub on split-usr systems ([c1588995](https://github.com/dracutdevs/dracut/commit/c1588995ae0d9f984ad08f2d466f7a09646c6517))
  *  silence the output of hardlinking files by default ([2a26eec5](https://github.com/dracutdevs/dracut/commit/2a26eec5cc1f384f71226066f13db89f92913f28))
  *  handle imagebase for uefi ([6178a9d8](https://github.com/dracutdevs/dracut/commit/6178a9d83ffad67fa371cef2ff3f5bbb337bc8b7))
  *  handle /etc/machine-id empty or uninitialized ([97fe0976](https://github.com/dracutdevs/dracut/commit/97fe09769d6a86492c39e0368f088f54f7c0fa6e))
  *  use dynamically uefi's sections offset ([f32e95bc](https://github.com/dracutdevs/dracut/commit/f32e95bcadbc5158843530407adc1e7b700561b1))
  *  kmoddir does not handle trailing / ([1ddcb137](https://github.com/dracutdevs/dracut/commit/1ddcb137ea2a4d79491ff94f1f7802dcaa7ac381))
  *  handle sbsign errors for UEFI builds ([a6dd5bfb](https://github.com/dracutdevs/dracut/commit/a6dd5bfb9a514a3bf650cc1e8d4311c05e9b968c))
  *  handle out of space error for UEFI builds ([8602df70](https://github.com/dracutdevs/dracut/commit/8602df705879100be17e93fe56f5cbeb6216248f))
  *  --sysroot option broken if global variables not set in conf ([6f4a5c90](https://github.com/dracutdevs/dracut/commit/6f4a5c90ab993d2559720c2d4023d99ad43df00a))
  *  correct --help and --version exit codes ([cda6b00a](https://github.com/dracutdevs/dracut/commit/cda6b00abce0e68e353ab929b86cfaf45c3dc1c8))
* **fido2:**  libfido2.so depends on libz.so ([15970768](https://github.com/dracutdevs/dracut/commit/1597076887c6744b9ec69c0ac44a1134fd700700))
* **fips:**
  *  move fips-boot script to pre-pivot ([d777dd3d](https://github.com/dracutdevs/dracut/commit/d777dd3dab50c2e383c00751fae5d9593339315f))
  *  only unmount /boot if it was mounted by the fips module ([ab26ad2c](https://github.com/dracutdevs/dracut/commit/ab26ad2c2ab4a5884e392951998d40829f130387))
  *  do not blindly remove /boot ([1fabbb64](https://github.com/dracutdevs/dracut/commit/1fabbb6412b70bdd1aac5279b90b9a23a267ffc5))
* **fs-lib:**  remove quoting form the first argument of the e2fsck call ([9aa332ca](https://github.com/dracutdevs/dracut/commit/9aa332cad7196b6e05b9e2f1810dc54bb38ed2ac))
* **github:**  exempt issues in a milestone ([c8a703aa](https://github.com/dracutdevs/dracut/commit/c8a703aaa7bbfe4f078fef5a4318243db059b87b))
* **install:**  do not undef _FILE_OFFSET_BITS ([70aeb4c1](https://github.com/dracutdevs/dracut/commit/70aeb4c1a56027bc2fe5570c080d96625b377c94))
* **install.d:**
  *  do not create initramfs if the supplied image is UKI ([b2af8c8b](https://github.com/dracutdevs/dracut/commit/b2af8c8bcfc72802e02e2c0adc2eed9279101624))
  *  respect even more kernel-install vars, plus style fixes ([17b8649e](https://github.com/dracutdevs/dracut/commit/17b8649eb931f3f4990ac8184fe23fc257df6fa5))
  *  respect more kernel-install env variables ([a037634a](https://github.com/dracutdevs/dracut/commit/a037634ad71711d29828214830ebdade0c449dbc))
* **integrity:**  do not require ls ([a804945f](https://github.com/dracutdevs/dracut/commit/a804945f27a0ccc2f69ae694599b1afec2afe8b1))
* **iscsi:**
  *  prefix syntax for static iBFT IPv6 addresses ([c3b65a49](https://github.com/dracutdevs/dracut/commit/c3b65a493a635a3f85f9e65c4337cd4c144ff8fc))
  *  install 8021q module unconditionally ([aa5d9526](https://github.com/dracutdevs/dracut/commit/aa5d9526eca23f642fd623d2c857fd8f9930b83d))
* **kernel-modules:**
  *  add interconnect drivers ([afb5717e](https://github.com/dracutdevs/dracut/commit/afb5717e67727d49fae0d2a1a4169e5b247387f4))
  *  add UFS drivers ([89269d23](https://github.com/dracutdevs/dracut/commit/89269d239f0539b7bd4339ba98a0d1b188b59962))
  *  use modalias info in get_dev_module() ([87a76dbb](https://github.com/dracutdevs/dracut/commit/87a76dbb578aff473e690857d1b714eacd92b9ec))
* **load_fstype:**  avoid false positive searchs ([10cf8e46](https://github.com/dracutdevs/dracut/commit/10cf8e46f43a7a2094e4d861c1296db6af0e0fa1))
* **lsinitrd.sh:**
  *  handle /etc/machine-id empty or uninitialized ([971b302d](https://github.com/dracutdevs/dracut/commit/971b302d70fbbfac3b6047654b7dc7ceeb1c17e7))
  *  handle filenames with special characters ([1f84ff88](https://github.com/dracutdevs/dracut/commit/1f84ff882fe272ef0185a284eee82e89735c833d))
* **lvmthinpool-monitor:**  activate lvm thin pool before extend its size ([e9b47742](https://github.com/dracutdevs/dracut/commit/e9b4774239989257999053033fc92cded7803896))
* **man:**
  *  add missing initrd-root-device.target to flow chart ([f11e8fff](https://github.com/dracutdevs/dracut/commit/f11e8fffc2db1f6f02d09207a1edbf1d898249d7))
  *  remove duplicate entry ([6af3fcfd](https://github.com/dracutdevs/dracut/commit/6af3fcfd7f699ec4bb3f1e9ac71b7a9ebb9804b3))
* **modsign:**  load keys to correct keyring ([b7ef1302](https://github.com/dracutdevs/dracut/commit/b7ef1302715bead649625666f92eff434082de1f))
* **multipath:**  remove dependency on multipathd.socket ([297525c5](https://github.com/dracutdevs/dracut/commit/297525c5c0781e13c4bf86aa42e81b9f166802ad))
* **network:**
  *  IPv6: don't wait for RA for static IPv6 assignments ([726d56ca](https://github.com/dracutdevs/dracut/commit/726d56ca0a23e5a39de5f809da2d20ce7985d437))
  *  don't assume prefix length 64 by default ([7ff255a4](https://github.com/dracutdevs/dracut/commit/7ff255a4488f63cf84179d4572f44fe3a1bd29ec))
* **network,dbus:**  improve dependency checking ([3f8f115a](https://github.com/dracutdevs/dracut/commit/3f8f115a27b2bb63f0893262b6c951a187bac8ef))
* **network-legacy:**
  *  typo ([e2f961a2](https://github.com/dracutdevs/dracut/commit/e2f961a2bd7b5f5cbff6394d6be6eace15e236b7))
  *  always include af_packet ([b074216b](https://github.com/dracutdevs/dracut/commit/b074216be93dc4512b76fcd6b77a727aef11b22b))
* **network-manager:**  add "After" dependency on dbus.service ([d8a9a73d](https://github.com/dracutdevs/dracut/commit/d8a9a73df9688989b5e47469e74ad5aa666a5bfb))
* **nvmf:**
  *  support /etc/nvme/config.json ([f07117d6](https://github.com/dracutdevs/dracut/commit/f07117d68d07d52aa4ce8b4b2549a0cb716b7f4b))
  *  install 8021q module unconditionally ([902f3a8f](https://github.com/dracutdevs/dracut/commit/902f3a8f84643e4249b9bbb2e81d1b13eaf35364))
* **plymouth:**  remove /etc/system-release dependency ([d6cef3f2](https://github.com/dracutdevs/dracut/commit/d6cef3f28e15a834284786c79f108b7c42481f96))
* **release:**  maintain dracut-version.sh in the source tree ([b4e23ce4](https://github.com/dracutdevs/dracut/commit/b4e23ce4238821b0c2dd3c846da45f9cfeb57954))
* **resolve-deps:**  check the existing file—not the source ([5ac581ef](https://github.com/dracutdevs/dracut/commit/5ac581ef66dd8f1939e771419824137aebbc8f66))
* **systemd:**
  *  add new systemd-tmpfiles-setup-dev-early.service ([7528d84d](https://github.com/dracutdevs/dracut/commit/7528d84de84d9c1fb7d5f54712c692600e21b044))
  *  do not include systemd-random-seed.service ([925febf8](https://github.com/dracutdevs/dracut/commit/925febf89d54c0bef9e3c8fda3b8e5b1f8ba30cd))
* **systemd-ac-power:**  correct systemd-ac-power binary path ([df2458a6](https://github.com/dracutdevs/dracut/commit/df2458a6b8aec70e74757ea7ae35f672a99ddc17))
* **systemd-journald:**  do not include systemd-journal-flush.service ([eff2a939](https://github.com/dracutdevs/dracut/commit/eff2a9398120b29fd869eec991410e254d0dcbb8))
* **systemd-networkd:**
  *  correct typos in override paths ([f0dc7ec9](https://github.com/dracutdevs/dracut/commit/f0dc7ec96b81fec100a5ab948c12846b2b9910e6))
  *  add missing conf files and services ([71e391eb](https://github.com/dracutdevs/dracut/commit/71e391ebdc8f5d88447db1b6d475c813d82d5ffb))
* **systemd-pcrphase:**  only include systemd-pcrphase-initrd.service ([cd6f683d](https://github.com/dracutdevs/dracut/commit/cd6f683d634970112a29867137431d0d57f8c957))
* **systemd-resolved:**  correct typo in override path ([2d083021](https://github.com/dracutdevs/dracut/commit/2d083021910f0633035a056e0541549efffec896))
* **systemd-timedated:**  correct typo in override path ([765e69ce](https://github.com/dracutdevs/dracut/commit/765e69ce4d88a4ef6c1028cc117b3f233a285f0e))
* **systemd-tmpfiles:**  do not include systemd-tmpfiles-clean.timer ([1ef00735](https://github.com/dracutdevs/dracut/commit/1ef00735ae4fa19684598a8f7868e8b36b6bf5fe))
* **systemd-udevd:**  add missing override paths ([570b9d40](https://github.com/dracutdevs/dracut/commit/570b9d405116c9763266aa2e88ea0a2460c734ba))
* **test:**
  *  only use QEMU machine q35 on x86 ([f29e428b](https://github.com/dracutdevs/dracut/commit/f29e428bdb3068e25150bc9591a961bd2df66442))
  *  use bash for jobs -r parameter ([9a18f133](https://github.com/dracutdevs/dracut/commit/9a18f1335fcab1eb84fedc45e450851d093335aa))
  *  rename test 60 ([3d7c0ffb](https://github.com/dracutdevs/dracut/commit/3d7c0ffbd65c8d5c9fef559a51a2405a28c6f6a0))
  *  improve test 60 ([5e846cb1](https://github.com/dracutdevs/dracut/commit/5e846cb1320e32db1e3d200743f8fc08732d4c9e))
  *  remove leftover link file from server rootfs ([8f44740f](https://github.com/dracutdevs/dracut/commit/8f44740f2c234ddb275e0a11e23d45e3678eb4a0))
  *  assign fixed address to bridge ([9fb64d96](https://github.com/dracutdevs/dracut/commit/9fb64d96ab7a7e19a7940e56e9bc0da863b46386))
  *  bump DHCP timeout to 30 seconds ([462d9b92](https://github.com/dracutdevs/dracut/commit/462d9b9254d4386e9eac267547ee4e8cd2487c3d))
  *  remove check on dhclient support for --timeout ([da959483](https://github.com/dracutdevs/dracut/commit/da959483333c6ab83e4cdef837130eacec6b35d7))
  *  adapt multinic test for new NetworkManager versions ([d3993c7d](https://github.com/dracutdevs/dracut/commit/d3993c7dabdd37c54a991c6ad9ea38365598d16a))
* **udev-rules:**
  *  remove firmware.rules ([7310a641](https://github.com/dracutdevs/dracut/commit/7310a641e227aae446684baeb48f878c3299ff9f))
  *  remove old eudev specific rule ([6d554d9b](https://github.com/dracutdevs/dracut/commit/6d554d9b98333372aeb20fd153a42c8171979825))
  *  remove old redhat specific rule ([d648bf80](https://github.com/dracutdevs/dracut/commit/d648bf805a27cbf1920f0437606c9ffb2684ec18))
  *  remove old edd_id extra rules ([6a33e677](https://github.com/dracutdevs/dracut/commit/6a33e677aca49dd81826949b61acb945d672ba84))
  *  remove old debian specific rules ([1edc41af](https://github.com/dracutdevs/dracut/commit/1edc41af979e1c1097be082c357f7a4895fbbad2))
* **url-lib.sh:**  nfs_already_mounted() with trailing slash in nfs path ([966b6cec](https://github.com/dracutdevs/dracut/commit/966b6cec1bebd91ddd0f85c357f7ab57d3213f51))
* **virtiofs:**  add virtio_pci kernel module to virtiofs ([07b49a3e](https://github.com/dracutdevs/dracut/commit/07b49a3ed79a792cede7e6ee21be29aba07168bc))

#### Features

* **Makefile:**  allow setting dracut version via environment variables ([31c4d284](https://github.com/dracutdevs/dracut/commit/31c4d284017044b72ddea767c4d35d6d70473984))
* **dracut:**
  *  add --sbat option to add sbat policy to UKI ([fffeaded](https://github.com/dracutdevs/dracut/commit/fffeadedf2170563cb7c0e0cb06994b0878ed455))
  *  use log level indicator in console output ([ae88e029](https://github.com/dracutdevs/dracut/commit/ae88e029c6ad20248d229bebd7e8f10d3d094988))
* **dracut-init.sh:**
  *  do not print by default if an udev rule is skipped ([aa20bbb5](https://github.com/dracutdevs/dracut/commit/aa20bbb5b1c78963331fb6261763ea4c51ebc04f))
  *  specify if a module cannot be found or cannot be installed ([a10078a5](https://github.com/dracutdevs/dracut/commit/a10078a5c3ce9adf309962634e71ae6e186f2621))
* **dracut-install:**  add fw_devlink suppliers as module dependencies ([3de4c731](https://github.com/dracutdevs/dracut/commit/3de4c7313260fb600507c9b87f780390b874c870))
* **fips:**  add progress messages ([68d0653e](https://github.com/dracutdevs/dracut/commit/68d0653e35f79e78b75a71c122c091ba4f4d5759))
* **install.d:**  allow using dracut in combination with ukify ([16645633](https://github.com/dracutdevs/dracut/commit/166456331d55cdc23946c11315dc2c88aab15911))
* **kernel-modules:**  driver support for macbook keyboards ([df381b7e](https://github.com/dracutdevs/dracut/commit/df381b7e0cd95f78e40ac70f0f3c96a2fa8dd189))
* **livenet:**  add memory size check depending on live image size ([52351cfa](https://github.com/dracutdevs/dracut/commit/52351cfa049a9594d539e6a5337d591e8039ab80))
* **lsinitrd:**  notify user on missing compressor ([1300a930](https://github.com/dracutdevs/dracut/commit/1300a930e76dbb380c7840760207296a1e58364c))
* **lvm:**  always include all drivers that LVM can use ([a109c612](https://github.com/dracutdevs/dracut/commit/a109c6123ffa8506379b73a4b1aeee4d0b67866d))
* **network-wicked:**  remove module ([9dbbebb1](https://github.com/dracutdevs/dracut/commit/9dbbebb1339d1c3dc8e6b8835a6edbc95c66e2fe))
* **nvmf:**  add code for parsing the NBFT ([b490f6f7](https://github.com/dracutdevs/dracut/commit/b490f6f7d7cf1c322b47af4e44d7f238612fb260))
* **resume:**  also consider resume= in the cmdline as enabling hibernation ([e3a7112b](https://github.com/dracutdevs/dracut/commit/e3a7112bef794e2f2dd741ec2c74fa9cb9117651), closes [#924](https://github.com/dracutdevs/dracut/issues/924))
* **systemd:**  install systemd-executor ([bee1c482](https://github.com/dracutdevs/dracut/commit/bee1c4824a8cd47ce6c01892a548bdc07b1fa678))
* **systemd-creds:**  introducing the systemd-creds module ([48c2cb45](https://github.com/dracutdevs/dracut/commit/48c2cb457b1472d09453be130797bc6e0e194f7c))
* **systemd-rfkill:**  remove module ([c4e6eaf9](https://github.com/dracutdevs/dracut/commit/c4e6eaf9c61616a2f27ef6e91cc787888afecde4))
* **test:**  nfs_fetch_url test into nfs test ([8f9ad068](https://github.com/dracutdevs/dracut/commit/8f9ad06873eb50754611ece2c18a0cd0b22336c0))

#### Contributors

- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- Henrik Gombos <henrik99999@gmail.com>
- Laszlo Gombos <laszlo.gombos@gmail.com>
- Benjamin Drung <benjamin.drung@canonical.com>
- Beniamino Galvani <bgalvani@redhat.com>
- Martin Wilck <mwilck@suse.de>
- наб <nabijaczleweli@nabijaczleweli.xyz>
- Adrien Thierry <athierry@redhat.com>
- Frederick Grose <fgrose@sugarlabs.org>
- Andrew Ammerlaan <andrewammerlaan@gentoo.org>
- Pavel Valena <pvalena@redhat.com>
- Frantisek Sumsal <frantisek@sumsal.cz>
- Jóhann B. Guðmundsson <johannbg@gmail.com>
- Tao Liu <ltao@redhat.com>
- “Masahiro <mmatsuya@redhat.com>
- 0x5c <dev@0x5c.io>
- Andrew Halaney <ahalaney@redhat.com>
- Daniel McIlvaney <damcilva@microsoft.com>
- David Disseldorp <ddiss@suse.de>
- Dmitry Klochkov <dmitry.klochkov@bell-sw.com>
- Emanuele Giuseppe Esposito <eesposit@redhat.com>
- John Meneghini <jmeneghi@redhat.com>
- Khem Raj <raj.khem@gmail.com>
- LinkTed <link.ted@mailbox.org>
- Lubomir Rintel <lkundrak@v3.sk>
- Michal Koutný <mkoutny@suse.com>
- Michał Zegan <webczat@outlook.com>
- Mike Gilbert <floppym@gentoo.org>
- Sam James <sam@gentoo.org>
- Sergio E. Nemirowski <sergio@outerface.net>
- Thomas Blume <thomas.blume@suse.com>
- Tianhao Chai <cth451@gmail.com>
- Valentin Lefebvre <valentin.lefebvre@suse.com>
- Vitaly Kuznetsov <vkuznets@redhat.com>
- keentux <valentin.lefebvre@suse.com>
- lilinjie <lilinjie@uniontech.com>

dracut-059
==========

#### Bug Fixes

* **NEWS.md:**  add missing entries ([794ce5e3](https://github.com/dracutdevs/dracut/commit/794ce5e3ee55f1b78be32873a054aed422346f4c))

#### Contributors

- Jóhann B. Guðmundsson <johannbg@gmail.com>

dracut-058
==========

#### Bug Fixes

* **90kernel-modules:**
  *  MMC and NVMe on kernels 6.0+ ([e0d57a8f](https://github.com/dracutdevs/dracut/commit/e0d57a8f5b15847a7fbae2ed3df29ec2c5d25ec7))
  *  add (nonstandard) NVMe drivers ([415e5519](https://github.com/dracutdevs/dracut/commit/415e5519d19e24d123378710abe47a2df2b22e7b))
* **90multipath:**
  *  use RemainAfterExit=yes for multipathd-configure.service ([2334031a](https://github.com/dracutdevs/dracut/commit/2334031a890a1101c78f986681236c76ba806d91))
  *  create `/etc/multipath` only ([0940be90](https://github.com/dracutdevs/dracut/commit/0940be905843e93111e96c0d70c56389240fbc04))
* **Makefile:**  reduce the number of shell invocations ([ad7d5bc8](https://github.com/dracutdevs/dracut/commit/ad7d5bc8ea181ef805f65ae690681ebe5ba29bbe))
* **base:**
  *  do not require chroot inside initramfs ([51813371](https://github.com/dracutdevs/dracut/commit/518133714b769160448a51c512d5e152ea6332da))
  *  remove grep dependency ([240a1d34](https://github.com/dracutdevs/dracut/commit/240a1d34bd5d98fb8a7d75cd1053d8abf1c73f64))
* **dbus-broker:**  add missing sockets.target.wants/dbus.socket ([7ed04618](https://github.com/dracutdevs/dracut/commit/7ed0461810602bfbd4d5492fc9ed82f15e57fa9f))
* **dmsquash-live:**
  *  add support for NFS ([8caaad4f](https://github.com/dracutdevs/dracut/commit/8caaad4fc2d75982eb87f5ebc72a4c276986f756))
  *  check kernel for built-in squashfs drivers ([922c9e28](https://github.com/dracutdevs/dracut/commit/922c9e28ed87815cf6ae0b5ee911ff0ef616d1b0))
  *  run checkisomd5 on correct device ([c8f819e6](https://github.com/dracutdevs/dracut/commit/c8f819e6c1c38e525e4b491b4215a939ee6e00df))
* **dmsquash-live-ntfs:**  remove unnecessary command ([e78f71b9](https://github.com/dracutdevs/dracut/commit/e78f71b9da29828ee4cd8444d4841ee127ef8614))
* **dmsquash-live-root:**  check kernel for built-in `overlay` drivers ([d0cd7cd3](https://github.com/dracutdevs/dracut/commit/d0cd7cd38711b5425777c3b1595dbf4288beaa23))
* **dracut:**
  *  allow to set persistent policy based on /dev/mapper device names ([9cc7ceec](https://github.com/dracutdevs/dracut/commit/9cc7ceec1e9b4028d1a72bf51f9ea488d7ca11ac))
  *  shellcheck regression in DRACUT_INSTALL calls ([097dd367](https://github.com/dracutdevs/dracut/commit/097dd367bbd61da1577a182c535c5aacdfd07031))
  *  replace invalid lzo command with lzop for LZO compression ([b2d7561b](https://github.com/dracutdevs/dracut/commit/b2d7561b98d08c7e4018aa22dc36dc1242e50f09))
  *  typo error 'aggresive' -> 'aggressive' ([e4f1dbcc](https://github.com/dracutdevs/dracut/commit/e4f1dbcc0061113cb58e555724f76a7243788236))
* **dracut-functions.sh:**
  *  check_kernel_module should follow dracutsysrootdir ([6c42d378](https://github.com/dracutdevs/dracut/commit/6c42d378abe528ee6f10c8272080eec5f3f44acb))
  *  suppress findmnt error msg if /etc/fstab not exist ([e9ed44c8](https://github.com/dracutdevs/dracut/commit/e9ed44c8864445d85018e31064cd888c358f1daf))
* **dracut-init:**  make require_kernel_modules ignore no kernel build ([d460941b](https://github.com/dracutdevs/dracut/commit/d460941b51d0178683b9098e62ad57e43fb71011))
* **dracut-init.sh:**
  *  instmods: wrong variable name ([b12ee558](https://github.com/dracutdevs/dracut/commit/b12ee558f5660073ad26415794570188e8a427b0))
  *  add missing hostonly code in the inst_multiple function ([e2fdb30b](https://github.com/dracutdevs/dracut/commit/e2fdb30b56305aed9d3be32f394352c7c3fdbcef))
  *  correct dracut-install source path ([72b700e3](https://github.com/dracutdevs/dracut/commit/72b700e3cb8a0d74033e6e20b2435d9254b36efe))
  *  propagate the result code returned by dracut-install ([d2f6f445](https://github.com/dracutdevs/dracut/commit/d2f6f445edb5de033d52ece0e982db38ac2614e2))
* **dracut-initramfs-restore.sh:**
  *  initramfs detection not working ([481b87fa](https://github.com/dracutdevs/dracut/commit/481b87fa7a82be54663071ad9ad76c34e378ddc7))
  *  hide unpack errors ([4f20ae26](https://github.com/dracutdevs/dracut/commit/4f20ae2620a9067270fe3e5f191ada6bff7b0ec1))
* **dracut-install:**
  *  use stripped kernel module path as hash key ([2f791b40](https://github.com/dracutdevs/dracut/commit/2f791b401b287f67f2421452b5f82cdb5285a637))
  *  do not try to copy files from the root directory ([ebbcf97d](https://github.com/dracutdevs/dracut/commit/ebbcf97dc7267f47ae568909305bcb05de2876b4))
  *  correctly waitpid() for cp ([13736c50](https://github.com/dracutdevs/dracut/commit/13736c50c797d63ab75468ded17bc7935d7f1f94))
  *  convert_abs_rel: return valid path on error ([06d31617](https://github.com/dracutdevs/dracut/commit/06d316171cd5e0e86c21006f93776ba9f49087cc))
* **dracut-logger.sh:**  this fixes the dlog_init check for /dev/log ([6b592f58](https://github.com/dracutdevs/dracut/commit/6b592f581c1a5ec489acee95779867e0485770fd))
* **dracut-systemd:**  run systemctl daemon-reload after remove_hostonly_files ([e1058b07](https://github.com/dracutdevs/dracut/commit/e1058b07ea2acb1bdb2d52f778639e093b1ed8a6))
* **dracut.sh:**
  *  split drivers_dir check ([d32d221e](https://github.com/dracutdevs/dracut/commit/d32d221efd77dcc0afa1d39230f7bdc2958ffca5))
  *  use DRACUT_ARCH instead of `uname -m` ([a86aea65](https://github.com/dracutdevs/dracut/commit/a86aea65186b47ac210a3947c966311bb5371aeb))
  *  make omit-drivers option do exact match for names ([444944ab](https://github.com/dracutdevs/dracut/commit/444944ab37c2446adf07dd163225707e90aabef3))
  *  correct wrong systemd variable paths ([b9dc999f](https://github.com/dracutdevs/dracut/commit/b9dc999f87a477af53e379d7fb1053d13d6dbe88))
  *  remove duplicate "dracut:" string in logger functions ([8410ee22](https://github.com/dracutdevs/dracut/commit/8410ee22903403cd673a22692a084125c835cbe9))
  *  do not fail on irregular files ([b72d0d7f](https://github.com/dracutdevs/dracut/commit/b72d0d7f9be53c1ad04f132daf0297aff7581e9c))
* **dracut.spec:**  tpm2-tools is required for crypt module to work ([8abffe7c](https://github.com/dracutdevs/dracut/commit/8abffe7cca2e210e15c618beeffe7450be357f73))
* **drm:**  add video drivers needed on hyper-v and similar ([85149b85](https://github.com/dracutdevs/dracut/commit/85149b85961aa535a3c61d492cd3594794e5cc3f))
* **github:**  yml syntax and commit message for dependabot ([32f6dd1d](https://github.com/dracutdevs/dracut/commit/32f6dd1d5f0b7c24bda8bf950df176a0791045cb))
* **i18n:**
  *  do not fail if FONT in /etc/vconsole.conf has the file extension ([e1de5bd2](https://github.com/dracutdevs/dracut/commit/e1de5bd2d711df2c6814a3c3ab8472cdb4de9101))
  *  add required includes for keymaps ([fe8fa2b0](https://github.com/dracutdevs/dracut/commit/fe8fa2b0cadbb33e27c8dd8b5851548dcd65835c))
* **install.d:**  add --verbose if KERNEL_INSTALL_VERBOSE=1 ([846a8453](https://github.com/dracutdevs/dracut/commit/846a845375b8a9ea48741079d523e6b464950ea7))
* **integrity:**
  *  do not enable EVM if there is no key ([90585c62](https://github.com/dracutdevs/dracut/commit/90585c624af15ba0abb7f32b0c2afc2b122dd019))
  *  remove unused variable ([9d1004a4](https://github.com/dracutdevs/dracut/commit/9d1004a4e9883ecabdca478a809efb5501a1e47a))
* **iscsi:**  don't install the module if kernel doesn't support iscsi ([7917d797](https://github.com/dracutdevs/dracut/commit/7917d7976ded6384433ef8fb2ce1905f0a76358e))
* **kernel-modules:**
  *  add sysctl to initramfs to handle modprobe files ([33679fff](https://github.com/dracutdevs/dracut/commit/33679fff5deb733f9dfe8d005066ac98e107c083))
  *  always include nvmem driver on nvmem_on_arm ([bc965cd8](https://github.com/dracutdevs/dracut/commit/bc965cd8890013a6362733d217c18756134bbcdf))
* **load_fstype:**  use $1 if $2 is missing ([401158e5](https://github.com/dracutdevs/dracut/commit/401158e58c47b2e1278a47b9cd236f501cfe2732))
* **lsinitrd.sh:**
  *  add a missing path to image ([e877be69](https://github.com/dracutdevs/dracut/commit/e877be69b41199ee4384ccb6352754bb9edfbba4))
  *  correct skipcpio source path ([5eb996a9](https://github.com/dracutdevs/dracut/commit/5eb996a9936a87918a4320963a8681975ed86be4))
* **lvm:**  drop dm-eventd binary and libs from initramfs ([7d3184e4](https://github.com/dracutdevs/dracut/commit/7d3184e430823f7eee4acee87576acdcf02746c2))
* **man:**
  *  correct typo ([699e3945](https://github.com/dracutdevs/dracut/commit/699e39458962bc1a06a096f24ad86ffb87e8779e))
  *  dracut.cmdline.7: clarify "rd.nvmf.discover=fc,auto" ([a90efdd7](https://github.com/dracutdevs/dracut/commit/a90efdd704271dab6717329e88b3a1c9e850d23b))
  *  dracut.cmdline(7): correct syntax for rd.nonvmf ([4b69e63b](https://github.com/dracutdevs/dracut/commit/4b69e63b7414567a03e8da79acc2efe32e0a6a94))
  *  point man pages to github.com instead of kernel.org ([d6d55584](https://github.com/dracutdevs/dracut/commit/d6d555845e53dca0b083d59c8cedf465e6b70b71))
  *  correct typo ([7fa0094c](https://github.com/dracutdevs/dracut/commit/7fa0094c0087a827a22f30ec62f03f243b000bf3))
* **multipath:**  install multipathd.socket ([02e646fc](https://github.com/dracutdevs/dracut/commit/02e646fc7ec91e1fbaa0f2097f35781ae41da937))
* **network:**
  *  check if ip command fails ([52d14607](https://github.com/dracutdevs/dracut/commit/52d14607d18d99c0c2c3242a64561b1af6a332d1))
  *  two bugs which cause minutes long boot times ([1d6f42c8](https://github.com/dracutdevs/dracut/commit/1d6f42c8a4029380c2147018e64fb7ebc9e175e7))
  *  avoid double brackets around IPv6 address ([2c26b703](https://github.com/dracutdevs/dracut/commit/2c26b703223bb65822954264bcd6ca7934c98b4a))
  *  don't use same ifname multiple times ([f4e9ea87](https://github.com/dracutdevs/dracut/commit/f4e9ea879f38bea92069e9397028caa5d81e5aee))
* **network-legacy:**
  *  check if dhclient has --timeout option ([23654c50](https://github.com/dracutdevs/dracut/commit/23654c50b003612d1b6e4b09c0bde7dd88239fd8))
  *  correct wrong local network configuration path ([2eb733cc](https://github.com/dracutdevs/dracut/commit/2eb733cc11c09358b79e2c73218953f5bb64da93))
* **network-manager:**
  *  always install the library plugins directory ([429f9de1](https://github.com/dracutdevs/dracut/commit/429f9de1c767c816301097a42cec762dc82d67da))
  *  correct wrong local network configuration path ([744c6de5](https://github.com/dracutdevs/dracut/commit/744c6de5cde38d012f93bc53f9076bf9c37b8b72))
* **nfs,virtiofs:**  check kernel for builtin fs drivers ([78cafe46](https://github.com/dracutdevs/dracut/commit/78cafe465d972ed52cc9d847c9895716a5f44e7e))
* **nvmf:**
  *  run cmdline hook before parse-ip-opts.sh ([a65fab69](https://github.com/dracutdevs/dracut/commit/a65fab69662d3adf52eb968411f59ebc5a173f7c))
  *  avoid calling "exit" in a cmdline hook ([a93968b0](https://github.com/dracutdevs/dracut/commit/a93968b07567a654d18b8ef2144337d803186eca))
  *  make sure "rd.nvmf.discover=fc,auto" takes precedence ([556ef46a](https://github.com/dracutdevs/dracut/commit/556ef46aa96650d72b2fd850a09fa04dff64bbb8))
  *  don't use "finished" queue for autoconnect ([e93e4652](https://github.com/dracutdevs/dracut/commit/e93e46520dd89a7357a15441ab6b141ff9ff9aeb))
  *  don't create did-setup file ([03921ec0](https://github.com/dracutdevs/dracut/commit/03921ec09e95ea49f89ae307dcca4e2e3d1bc6d6))
  *  no need to load the nvme module ([a3cf4ec9](https://github.com/dracutdevs/dracut/commit/a3cf4ec92202df43adf368c7fdd12e35d304a0e4))
  *  don't try to validate network connections in cmdline hook ([b3ff3f3f](https://github.com/dracutdevs/dracut/commit/b3ff3f3fbce6878a754332cd4a05374e5e1156c8))
  *  nvme list-subsys prints the address using commas as separator ([9664e98b](https://github.com/dracutdevs/dracut/commit/9664e98b5db603567d42d4d0c6e6ea1bd3d5bf24))
* **shell-completion:**  add missing -p and --parallel options ([b30a00c2](https://github.com/dracutdevs/dracut/commit/b30a00c2a2815517e79eeaeef5f76fd6f923e61f))
* **skipcpio:**  ignore broken pipe ([aa0369a4](https://github.com/dracutdevs/dracut/commit/aa0369a4a31764fde06214358b0774fb1095af01))
* **squash:**  build ld cache for squash loader ([bc1b23c2](https://github.com/dracutdevs/dracut/commit/bc1b23c29202023dd7852f4c3e3e97aaaf94da92))
* **systemd:**
  *  add missing modprobe@.service ([928252a1](https://github.com/dracutdevs/dracut/commit/928252a145ca44627ba5873e01245eabe246992f))
  *  set right permissions for the machine-id file ([da55e266](https://github.com/dracutdevs/dracut/commit/da55e2663499f6218d28783076c5449a9a6b8ec9))
* **systemd-coredump:**  correct systemd-coredump binary path ([4b931bfb](https://github.com/dracutdevs/dracut/commit/4b931bfb4f594834d06787b3506c4a0ddbbe48ac))
* **systemd-hostnamed:**
  *  add missing dbus-org.freedesktop.hostname1.service ([4fca292b](https://github.com/dracutdevs/dracut/commit/4fca292b957c8ec256111442ba0db4e539442ac8))
  *  correct sysusers configuration ([a540c95b](https://github.com/dracutdevs/dracut/commit/a540c95bbf9496f7b9d6e86aa5080173d73dff78))
* **systemd-networkd:**  typo in systemd-networkd.socket local conf path ([d4732be8](https://github.com/dracutdevs/dracut/commit/d4732be87782016c2699fbf980d63ac366819942))
* **systemd-timedated:**  add missing dbus-org.freedesktop.timedate1.service ([b3d219b4](https://github.com/dracutdevs/dracut/commit/b3d219b475c8f695ccfb8b741282583da710befa))
* **systemd-timesyncd:**  typo in systemd-time-wait-sync.service local conf path ([e3ec51e1](https://github.com/dracutdevs/dracut/commit/e3ec51e128135d56c3995d87ca2a4ff65b253391))
* **test:**  remove unnecessary setup steps ([22ab7979](https://github.com/dracutdevs/dracut/commit/22ab79794852eced9caaccd8763332b870e97032))
* **virtiofs:**
  *  make shebangs work on split-usr systems ([27b316df](https://github.com/dracutdevs/dracut/commit/27b316df1f001949675fbeddaeab6ff56bc449d2))
  *  ismounted has a dependency on the base module ([c73e7b99](https://github.com/dracutdevs/dracut/commit/c73e7b99db8c759d89236d0791145d6919abd2bc))
* **zipl:**  remove trailing spaces from zipl boot device name ([b4de9ee1](https://github.com/dracutdevs/dracut/commit/b4de9ee107742c8b0b8a86dcc22aa4fd366b068e))

#### Features

* **dmsquash-live:**
  *  add support for dash ([862ba526](https://github.com/dracutdevs/dracut/commit/862ba52683834f87722cae7a6692a59d09271ec3))
  *  add new dmsquash-live-autooverlay module ([a3c67d27](https://github.com/dracutdevs/dracut/commit/a3c67d27e75223bb45df19f850d246ced9a09938))
* **dracut-init.sh:**
  *  introduce a new helper require_kernel_modules ([d3a5e631](https://github.com/dracutdevs/dracut/commit/d3a5e6312a84b29bcb10fd5d28e1314f1acbc78f))
  *  add inst_libdir_dir() helper ([cc669250](https://github.com/dracutdevs/dracut/commit/cc669250affa0176ed2bba866d8e933fb0668f4c))
* **dracut-install:**  convert_abs_rel: canonicalise parent of from, too ([53dd6a9b](https://github.com/dracutdevs/dracut/commit/53dd6a9bbb0eb91dea0e56bec556bf865a920b2e), closes [#1781](https://github.com/dracutdevs/dracut/issues/1781))
* **dracut.sh:**
  *  populate uefi_cmdline if no other cmdline is given ([1157143d](https://github.com/dracutdevs/dracut/commit/1157143d67b02ccf95602ae082f6fbfd1a20f342))
  *  pass engine flag to sbsign allowing use with hardware devices ([897e5eff](https://github.com/dracutdevs/dracut/commit/897e5effe08f15de6b20099caeda7bc1167b7026))
* **fs-lib:**  fsck_single can now handle PARTLABEL and PARTUUID ([d40617f7](https://github.com/dracutdevs/dracut/commit/d40617f720ce7d895be4f6297ac4342d4492c39a))
* **github:**  automating dependency updates ([bdddfd56](https://github.com/dracutdevs/dracut/commit/bdddfd561f38469b3f51d7e6af196ff1f190e2a2))
* **kernel-modules:**  exclude USB drivers in strict hostonly mode ([7debf540](https://github.com/dracutdevs/dracut/commit/7debf540ca69d9171cb86b4752c882bac997c26e))
* **multipath:**  install tmpfiles.d config file ([cf31fcf8](https://github.com/dracutdevs/dracut/commit/cf31fcf804be4dc0fa31885f5185a59b6012cdf4))
* **nvmf:**  set rd.neednet=1 if tcp records encountered ([cf8986af](https://github.com/dracutdevs/dracut/commit/cf8986af7d9a3ce73f330de23d5312f924acea34))
* **overlayfs:**
  *  add new overlayfs module to dracut.spec ([b55563f6](https://github.com/dracutdevs/dracut/commit/b55563f635fb8aad5e141c4fa5d3e486dc2b0b60))
  *  add a new module called overlayfs ([40dd5c90](https://github.com/dracutdevs/dracut/commit/40dd5c90e0efcb9ebaa9abb42a38c7316e9706bd))
* **qemu:**  add efi_secret driver ([8194f72a](https://github.com/dracutdevs/dracut/commit/8194f72af2e9b6ab3cdb01412381023b0a58c852))
* **squash:**  use require_kernel_modules for better module checking ([d4a9d6b4](https://github.com/dracutdevs/dracut/commit/d4a9d6b4c006a375e0b89396251e8ad1aecc0b16))
* **systemd:**  install systemd-sysroot-fstab-check ([23684e4a](https://github.com/dracutdevs/dracut/commit/23684e4a2bb024595ad63d9f49d83b4693537110))
* **systemd-pcrphase:**  introducing the systemd-pcrphase module ([d345ca2e](https://github.com/dracutdevs/dracut/commit/d345ca2efd5e017be5cc80cfc96137a7f0bee425))
* **systemd-portabled:**  introducing the systemd-portabled module ([03babd95](https://github.com/dracutdevs/dracut/commit/03babd95e28bc884e87fd0885edafb2ee91f8935))
* **systemd-pstore:**  introducing the systemd-pstore module ([758f2e69](https://github.com/dracutdevs/dracut/commit/758f2e69374d7865bf55a74ee218a1d52df20123))
* **test:**  add new module to share code between tests ([f5689b42](https://github.com/dracutdevs/dracut/commit/f5689b42bdb9dfcb0f1b610d7db845ceac985061))
* **test-makeroot:**  add new module to share code between tests ([54b963ca](https://github.com/dracutdevs/dracut/commit/54b963ca35a3a4cc8bcdb35e5e9ebb74af09191e))
* **test-root:**  add new module to share code between tests ([b17a3103](https://github.com/dracutdevs/dracut/commit/b17a3103a516b5a45af954b1e2969a5256fffebc))

#### Performance

* **90kernel-modules:**  use awk instead of shell monster ([77ac95d9](https://github.com/dracutdevs/dracut/commit/77ac95d9091afcfdbd1fe0372389613914dd1bc6))
* **dracut-install:**
  *  convert_abs_rel: don't allocate target parent realpath ([d2648f6d](https://github.com/dracutdevs/dracut/commit/d2648f6dd8277c3d9a0b8d05ca66a212da47070e))
  *  strdup()+[dirlen]=0 => strndup ([e7d6a1e3](https://github.com/dracutdevs/dracut/commit/e7d6a1e30c34134d27c0ae921b7d18525ddf3dea))
* **dracut.sh:**  do not mkdir $initdir/lib/dracut within a loop ([8d46cc01](https://github.com/dracutdevs/dracut/commit/8d46cc01a95afc6902e8c86a795db082622a3c74))

#### Contributors

- Laszlo Gombos <laszlo.gombos@gmail.com>
- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- Martin Wilck <mwilck@suse.de>
- Kairui Song <kasong@tencent.com>
- Marcos Mello <marcosfrm@gmail.com>
- наб <nabijaczleweli@nabijaczleweli.xyz>
- David Tardon <dtardon@redhat.com>
- Jóhann B. Guðmundsson <johannbg@gmail.com>
- Matt Coleman <matt@datto.com>
- Pavel Valena <pvalena@redhat.com>
- Alberto Planas <aplanas@suse.com>
- Brian C. Lane <bcl@redhat.com>
- Jonathan Lebon <jonathan@jlebon.com>
- Lukas Nykryn <lnykryn@redhat.com>
- keentux <valentin.lefebvre@suse.com>
- Cole Robinson <crobinso@redhat.com>
- Daan De Meyer <daan.j.demeyer@gmail.com>
- Frederick Grose <4335897+FGrose@users.noreply.github.com>
- Frederick Grose <fgrose@sugarlabs.org>
- Hari Bathini <hbathini@linux.ibm.com>
- Henrik Gombos <henrik99999@gmail.com>
- Jeremy Linton <jlinton@redhat.com>
- Kenneth D'souza <kennethdsouza94@gmail.com>
- Laura Hild <lsh@jlab.org>
- Mike Gilbert <floppym@gentoo.org>
- Mikhail Novosyolov <m.novosyolov@rosalinux.ru>
- Neal Gompa <neal@gompa.dev>
- Scott Moser <smoser@brickies.net>
- Tao Liu <ltao@redhat.com>
- Tianhao Chai <cth451@gmail.com>
- gombi <gombi@>
- joamonwx <unknown>
- runsisi <runsisi@hust.edu.cn>
- tupper <tupper.bob@gmail.com>

dracut-057
==========

#### Bug Fixes

* **10i18n:**
  *  stop leaking shell options ([f3441cc7](https://github.com/dracutdevs/dracut/commit/f3441cc7c577554dde04a9fe90638f779bb0a411))
  *  stop leaking shell options ([35064768](https://github.com/dracutdevs/dracut/commit/35064768ebf14d3ec6bf3f7df52580fb4920ea3d))
* **Makefile:**  use of potentially unset variable ([1354d633](https://github.com/dracutdevs/dracut/commit/1354d6339a2e603fe0787bc028f9e7e1d49cbf82))
* **bluetooth:**
  *  accept compressed firmwares in inst_multiple ([09a1e5af](https://github.com/dracutdevs/dracut/commit/09a1e5afd2eaa7f8e9f3beaf8a48283357e7fea0))
  *  nullglob should not be needed ([36aaa74f](https://github.com/dracutdevs/dracut/commit/36aaa74f3641d375cb435298864fad1945444893))
  *  make $dbussystem/bluetooth.conf optional ([a38d9ec0](https://github.com/dracutdevs/dracut/commit/a38d9ec0320f3819a3b70dc5bb59f6d2fc570149))
* **configure:**  check for SYS-gettid during configure ([0ef40d88](https://github.com/dracutdevs/dracut/commit/0ef40d88124fe67726b8b5d8321dce064c727447))
* **connman:**  copy netroot.sh from the network module and install it ([f6d83f9f](https://github.com/dracutdevs/dracut/commit/f6d83f9f5cd4850468f26048f8eed015dc2bd0e0))
* **crypt:**  add missing is_keysource parameter to cryptroot-ask ([6c11a8fc](https://github.com/dracutdevs/dracut/commit/6c11a8fcee08c297a34bd5c5215a7a29d3529b85))
* **dmsquash-live:**
  *  mount live device with the correct type ([08ed7b2d](https://github.com/dracutdevs/dracut/commit/08ed7b2d0035eaa699c139bc9719f90190f6ffc1))
  *  permanent overlay on the same drive as LiveCD .iso ([9a884b3a](https://github.com/dracutdevs/dracut/commit/9a884b3afce1ebc8c6a6e5f62594ce708486a826))
* **dracut:**  default to correct firmware search paths ([95aeed89](https://github.com/dracutdevs/dracut/commit/95aeed8975dd5a2af782ec986f2af6176b585c59))
* **dracut-functions.sh:**  correct wrong comment ([0afa840e](https://github.com/dracutdevs/dracut/commit/0afa840e111e63da14edcb655886734b45d61c4b))
* **dracut-initramfs-restore.sh:**
  *  unpack uncompressed initrd as last option ([46886956](https://github.com/dracutdevs/dracut/commit/46886956211f8a436e2e9f81fc4972d2a297c3a3))
  *  check if SELINUXTYPE is set ([24d8f35b](https://github.com/dracutdevs/dracut/commit/24d8f35b9c162f42c58abd27fe9c75bbf76cbfe7))
* **dracut-install:**
  *  copy files preserving ownership attributes ([9ef73b6a](https://github.com/dracutdevs/dracut/commit/9ef73b6ad08c19c3906564e5a15c7908ed9a81c8))
  *  do not fail when SOURCE is optional and missing ([bd1a5ca9](https://github.com/dracutdevs/dracut/commit/bd1a5ca9ae9e347061e67e51be29335ab074ad95))
* **dracut-systemd:**
  *  drop misleading man page reference ([77c28b30](https://github.com/dracutdevs/dracut/commit/77c28b3020b7dede848d8282151f609d80905b05))
  *  correct service dependencies ([85fdff12](https://github.com/dracutdevs/dracut/commit/85fdff1212e708d335f035926f3c2a6b87bb1c3c))
* **dracut.cmdline.7:**  {=> must} also be specified ([27071e9a](https://github.com/dracutdevs/dracut/commit/27071e9a0e7928bccc45469eb659cdafb20f134b))
* **dracut.sh:**
  *  format usage and add missing options ([9bef7109](https://github.com/dracutdevs/dracut/commit/9bef71094eba84a9eac161fc45386ccd73bd2b34))
  *  always check that MACHINE_ID is not empty ([527fdfa1](https://github.com/dracutdevs/dracut/commit/527fdfa1517b7f010afa049fe6add71e4c916cdd))
  *  avoid calling dfatal before dracut-logger is sourced ([012d7db2](https://github.com/dracutdevs/dracut/commit/012d7db27da7416471ed49ee2ca666ab95837f47))
  *  add missing default output file paths ([28ef3bc6](https://github.com/dracutdevs/dracut/commit/28ef3bc6a6f1efcd8d8c16228a6dee9d563342e7))
  *  add missing --libdirs usage ([352e5917](https://github.com/dracutdevs/dracut/commit/352e59173152f13b242c598a735243f0f2850ff1))
  *  drop restorecon call ([33859892](https://github.com/dracutdevs/dracut/commit/3385989266ddb1c0685f9f7501f1835e9ce49730))
  *  error exporting sysctl variables ([4c355d05](https://github.com/dracutdevs/dracut/commit/4c355d05587b0432a6dc551b8693dbdc51a07962))
* **dracut.spec:**  add connman module ([d0c6ab21](https://github.com/dracutdevs/dracut/commit/d0c6ab21d906cc5b0e05e1107c48baffcbedb02c))
* **fedora.conf:**  vi binary is missing ([48541362](https://github.com/dracutdevs/dracut/commit/485413627f04fdc0c5c29958ce437718b262a99c))
* **github:**  remove packit ([8fd37d20](https://github.com/dracutdevs/dracut/commit/8fd37d20f4b7cc08ee0970e0249aac4cd5b47a4e))
* **ifcfg:**  avoid calling unavailable dracut-logger functions ([7103c4bc](https://github.com/dracutdevs/dracut/commit/7103c4bce9240d5896a0d207c216e0f6270ad2e8))
* **install:**  restore musl support ([ce55a85e](https://github.com/dracutdevs/dracut/commit/ce55a85ed5d902c19d75895508856f96ec2ceb1a))
* **integrity:**  do not display any error if there is no IMA certificate ([f63f411d](https://github.com/dracutdevs/dracut/commit/f63f411d52df613936082d646ab072447b8b9d7f))
* **iscsi:**
  *  do not exit in handle_netroot() if discovery failed ([319dc7fe](https://github.com/dracutdevs/dracut/commit/319dc7fe10585a19d1a051f8ad1ba0190f86ff1f))
  *  remove unneeded iscsi NOP-disable code ([a33a8df4](https://github.com/dracutdevs/dracut/commit/a33a8df43d33c9bdf85d7a5b7392585129a690f5))
* **kernel-network-modules:**  allow specifying empty --hostonly-nics ([ab6f5733](https://github.com/dracutdevs/dracut/commit/ab6f57339ad77b5bc116400f7b66580745bfc563))
* **lsinitrd.sh:**
  *  always check that MACHINE_ID is not empty ([d6343146](https://github.com/dracutdevs/dracut/commit/d6343146c1db69fc724ca666a5d9321af7fd0d46))
  *  add missing default paths ([49ea6c42](https://github.com/dracutdevs/dracut/commit/49ea6c42db7180eec5ba57e082a38d116f2d17a5))
* **lvm:**
  *  add missing grep requirement ([79f9d9e1](https://github.com/dracutdevs/dracut/commit/79f9d9e1c29a9c8fc046ab20765e5bde2aaa3428))
  *  ignore expected error message from lvm config ([7e03d81f](https://github.com/dracutdevs/dracut/commit/7e03d81fe3df932558d2b7280fa57da24ba955c0))
* **man:**
  *  add missing default paths ([ffc1985c](https://github.com/dracutdevs/dracut/commit/ffc1985cb26894c50487b7db2703e8715a4a7537))
  *  add missing --libdirs section ([a90dbd95](https://github.com/dracutdevs/dracut/commit/a90dbd958b19778044047f17559449fffdb94cc2))
* **network-manager:**  avoid calling unavailable dracut-logger functions ([b7059aef](https://github.com/dracutdevs/dracut/commit/b7059aef5962aad1dc8d96a0f600105a40867380))
* **nfs:**
  *  give /run/rpcbind ownership to rpc user ([d6159343](https://github.com/dracutdevs/dracut/commit/d615934311e25146bb37943bf1385a19dfdbd9e8))
  *  require and install needed binaries ([0e4df7a3](https://github.com/dracutdevs/dracut/commit/0e4df7a39dda388dc71ff6f749c8197cba4442b9))
* **nvmf:**
  *  deprecate old nvmf cmdline options ([e405501e](https://github.com/dracutdevs/dracut/commit/e405501e23462d151bba252133f4a6179bf79cf0))
  *  set executable bit on nvmf-autoconnect.sh ([25a92885](https://github.com/dracutdevs/dracut/commit/25a92885a9519701cc480298c2b082e2e2bf5ebe))
* **plymouth:**  hide dpkg-architecture stderr messages ([42e9d188](https://github.com/dracutdevs/dracut/commit/42e9d1889298c3d8badfb6f95e16e048ad83a1f6))
* **resume:**  correct call to block_is_netdevice function ([a7a4b76c](https://github.com/dracutdevs/dracut/commit/a7a4b76c4ad5794f5f8a24ecd5b495f1512d05f7))
* **shell-completion:**  add missing options ([1199f990](https://github.com/dracutdevs/dracut/commit/1199f990bb93b4e6bd56fa3df050b17fc7e6c378))
* **systemd-coredump:**  add systemd-sysusers dependency ([ce82e969](https://github.com/dracutdevs/dracut/commit/ce82e969f8faaccbb57be178833ef4e39f01cdf9))
* **systemd-journald:**  remove duplicate entry in inst_multiple ([d3ab2061](https://github.com/dracutdevs/dracut/commit/d3ab20615ef94370e43b042d913d5f787dd52430))
* **systemd-timesyncd:**  add systemd-sysusers dependency ([28b6adcb](https://github.com/dracutdevs/dracut/commit/28b6adcb27fb5240c01f7d41511ce02597aa27bd))
* **test:**
  *  dmsquash-live test without an iso ([6ee2baf3](https://github.com/dracutdevs/dracut/commit/6ee2baf314fc6aa3bb88ca52d11c9f599223eb77))
  *  remove stale comments ([b3ab3037](https://github.com/dracutdevs/dracut/commit/b3ab3037e8b9272498ed40131f30bf1831acab73))
  *  add support for dpkg to pass the test on debian ([a7dfdf6a](https://github.com/dracutdevs/dracut/commit/a7dfdf6acbf7a87fd2735541f06a062126966f69))
  *  nullglob should not be needed ([c7b3ac2b](https://github.com/dracutdevs/dracut/commit/c7b3ac2bd115521855b3ad8ce287cb1a9afca128))
* **udev-rules:**  add cdrom udev rules by default ([aebeb2ec](https://github.com/dracutdevs/dracut/commit/aebeb2ecdf76b7716fadbab8b216b8805d36a461))

#### Features

 *   add aarch64 uefi support ([8391a993](https://github.com/dracutdevs/dracut/commit/8391a993033e212a24635dd629c167354f0834f8))
 * **connman:**  introduce connman support module ([f30d0351](https://github.com/dracutdevs/dracut/commit/f30d03513f357a36d2ed48a522c7ef2a46bb0c5c))
 * **dracut:**
   *  support parallel execution with --parallel ([6d923262](https://github.com/dracutdevs/dracut/commit/6d92326201014cde9ab04b90367017f875d3b991))
   *  add zfs detection ([9582f027](https://github.com/dracutdevs/dracut/commit/9582f02773c5115e14fe0992ec2db3935cb0e6eb))
 * **dracut-install:**  support ZSTD-compressed firmware with .zst suffix ([9d8387ed](https://github.com/dracutdevs/dracut/commit/                             9d8387ed803dfc3e8b97d2e415a15083774d7ac6))
 * **dracut-systemd:**  use Documentation= to point to man page ([42e8f17c](https://github.com/dracutdevs/dracut/commit/                                       42e8f17c2481d33a3d6ba23f653c835e0cda6994))
 * **gensplash:**  remove module ([1befc641](https://github.com/dracutdevs/dracut/commit/1befc6416743a527824f0f2cc25471e86a6f8a79))
 * **lvm:**  add new module lvmthinpool-monitor ([d9812fc4](https://github.com/dracutdevs/dracut/commit/d9812fc4ae18a39c144140dd60cb03e16e0d2e06))
 * **man:**  add documentation for rd.luks.key.tout ([65e41b54](https://github.com/dracutdevs/dracut/commit/65e41b54600878e3e08bbe3b60f66524e1d166a8))
 * **squash:**
   *  add shell completion for --squash-compressor option ([e2aee2d4](https://github.com/dracutdevs/dracut/commit/e2aee2d436cf68c4515a381d620a963ff18dcf05))
   *  update the manual page for --squash-compressor ([3693bfef](https://github.com/dracutdevs/dracut/commit/3693bfef2fc252f5a4b18278c87a1076896b7fb5))
   *  decouple the compressor for dracut and dracut-squash ([90d9ae8c](https://github.com/dracutdevs/dracut/commit/90d9ae8ca814c26045ecea63fa15bd8959076d0d))
 * **url-lib.sh:**  add --retry-connrefused to default curl arguments ([90032a46](https://github.com/dracutdevs/dracut/commit/                                 90032a463190ab68f20f493894f667320466082d))
 * **virtiofs:**  virtiofs root filesystem support ([4632f799](https://github.com/dracutdevs/dracut/commit/4632f799954c18eb8f655efe05b1e6ce30246828))

#### Contributors

- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- Laszlo Gombos <laszlo.gombos@gmail.com>
- Pavel Valena <pvalena@redhat.com>
- David Tardon <dtardon@redhat.com>
- Tao Liu <ltao@redhat.com>
- наб <nabijaczleweli@nabijaczleweli.xyz>
- German Maglione <gmaglione@redhat.com>
- Jóhann B. Guðmundsson <johannbg@gmail.com>
- Nicolas Porcel <nicolasporcel06@gmail.com>
- Zoltán Böszörményi <zboszor@gmail.com>
- nkraetzschmar <nkraetzschmar@users.noreply.github.com>
- Benjamin Gilbert <bgilbert@redhat.com>
- Coiby Xu <coxu@redhat.com>
- Conrad Hoffmann <ch@bitfehler.net>
- David Teigland <teigland@redhat.com>
- James Morris <morisja@gmail.com>
- Lee Duncan <lduncan@suse.com>
- Martin Wilck <mwilck@suse.de>
- Masahiro Matsuya <mmatsuya@redhat.com>
- Michal Hecko <mhecko@redhat.com>
- Morten Linderud <morten@linderud.pw>
- Savyasachee Jha <genghizkhan91@hawkradius.com>
- Shreenidhi Shedi <sshedi@vmware.com>
- Wenchao Hao <haowenchao@huawei.com>

dracut-056
==========

#### Bug Fixes

* **base:**
    *  do not change the provided UUID ([4e858741](https://github.com/dracutdevs/dracut/commit/4e858741087a5cfea891bd2c1fd51ea9b830aeaf))
    *  add default device choice ([e8c18c9f](https://github.com/dracutdevs/dracut/commit/e8c18c9f7f5ed94898f70e9ff5a5f94a815a2b49))
    *  tr needs to be installed ([dfbfd33b](https://github.com/dracutdevs/dracut/commit/dfbfd33b24524c0c10ad3594be143192f5b7da84))
    *  do not quote $initargs for switch_root ([f649cd10](https://github.com/dracutdevs/dracut/commit/f649cd10b2e920e9d65c532db9b9f89a7370ad99))
    *  repair installing dracut-util ([d7acf107](https://github.com/dracutdevs/dracut/commit/d7acf107f2ac619f73dfa29588ea9adfaf79e296))
* **bluetooth:**
    *  make hostonly configuration files optional ([d03fb675](https://github.com/dracutdevs/dracut/commit/d03fb675d8e904c6c44de9b91814b33c45043f4f))
    *  dbus configuration path fixes ([34b1dd2e](https://github.com/dracutdevs/dracut/commit/34b1dd2e26c343e9000094db01a7985b6851adf1))
* **cms:**  reload NetworkManager connections ([07977ee5](https://github.com/dracutdevs/dracut/commit/07977ee5c5294a5d30c1f33f292a0b31303750fb))
* **cpio:**
    *  correct dev_t -> rmajor/rminor mapping ([acc629ab](https://github.com/dracutdevs/dracut/commit/acc629abb0d7a26f692f99e5a9cf8c8401bc6a86))
    *  write zeros instead of seek for padding and alignment ([0af11c5e](https://github.com/dracutdevs/dracut/commit/0af11c5ea5018a3e1049a2207a9a671049651876))
* **crypt:**  remove quotes from cryptsetupopts ([e0abf88a](https://github.com/dracutdevs/dracut/commit/e0abf88a15d23fbf793cf872397016ad86aeaaa8), closes [#1528](https://github.com/dracutdevs/dracut/issues/1528))
* **crypt-gpg:**
    *  tr needs to be installed ([a93fbc4a](https://github.com/dracutdevs/dracut/commit/a93fbc4ae00d8c6ecda67319a6425f7966609bbe))
    *  execute --card-status on each try ([66100936](https://github.com/dracutdevs/dracut/commit/6610093698db25fda1d584b9771da1e2c2330095))
* **dasd_rules:**
    *  correct udev dasd rules parsing ([5de6e4d5](https://github.com/dracutdevs/dracut/commit/5de6e4d56e5206cb47f645ad1cb6d39794048c68))
    *  remove collect based udev rule creators ([ebafbd82](https://github.com/dracutdevs/dracut/commit/ebafbd824175e201ae9476576588a896c6b7d7eb))
* **dmsquash-live:**
    *  option to use overlayfs on a block device root ([813577e2](https://github.com/dracutdevs/dracut/commit/813577e2ba034b448d2cf2d2857b2d20d56c0259))
    *  do not install systemd files when systemd is not enabled ([bf8738d3](https://github.com/dracutdevs/dracut/commit/bf8738d31ca53ad6410c46c1f9b2a4a12273b9a3))
    *  iso-scan requires rmdir ([e19e3890](https://github.com/dracutdevs/dracut/commit/e19e38904c054664473207d2d6ef3c53bd938867))
    *  correct regression introduced with shellcheck changes ([0c631efb](https://github.com/dracutdevs/dracut/commit/0c631efb10bf4ce18ec8640277bd94712950298a))
* **dmsquash-live-ntfs:**  fuse3 no longer requires ulockmgr_server ([75ad2699](https://github.com/dracutdevs/dracut/commit/75ad269931eccd266a5d60ba4000d93655143e00))
* **dracut:**  be more robust when using 'set -u' ([22a80629](https://github.com/dracutdevs/dracut/commit/22a80629b4bbcef02eb8fe3611ea44e253ef4c61))
* **dracut-functions.sh:**
    *  ip route parsing ([d754e1c6](https://github.com/dracutdevs/dracut/commit/d754e1c6f081a6501cb7fdcb5caaa6c4977235af))
    *  get block device driver if in a virtual subsystem ([dc3b976f](https://github.com/dracutdevs/dracut/commit/dc3b976f3393d7a3fb75b349418fc8ee2c9142bd))
* **dracut-init:**  unbreak a comment ([bc4f196f](https://github.com/dracutdevs/dracut/commit/bc4f196f9825029eaef7ccf525ec57f5229b2793))
* **dracut-initramfs-restore.sh:**
    *  add missing compression options ([e86397de](https://github.com/dracutdevs/dracut/commit/e86397de24f4efa6d36e2bb5ae84b7d9ec69b72d))
    *  add missing default paths ([3d8e1ad2](https://github.com/dracutdevs/dracut/commit/3d8e1ad2ae1e34244ddf700beea6358c1452e05c), closes [#1628](https://github.com/dracutdevs/dracut/issues/1628))
* **dracut-install:**  tweaks to get_real_file() ([1beeaf3b](https://github.com/dracutdevs/dracut/commit/1beeaf3b71aed763d5fc7a9ee044d675f8906e8c))
* **dracut-shutdown:**  add cleanup handler on failure ([7ab1d002](https://github.com/dracutdevs/dracut/commit/7ab1d00227cad6f1b86ba01fdc766769faebb031))
* **dracut-systemd:**  do not use Requires for vconsole-setup.service ([a7f5429c](https://github.com/dracutdevs/dracut/commit/a7f5429cb81f7ffdf9bd5684af8d36725170b756))
* **dracut.sh:**
    *  do not ignore invalid config file or dir path ([7de9ffc0](https://github.com/dracutdevs/dracut/commit/7de9ffc0574790ecbad74b5a000ecd022d7736d4))
    *  check kernel zstd support early ([475497b1](https://github.com/dracutdevs/dracut/commit/475497b1bd12c006c782541124b6427cb7ef4cb7))
    *  check availability of configured compression ([bdac657b](https://github.com/dracutdevs/dracut/commit/bdac657bf65615438942a872491a818750735014))
    *  inform user about auto-selected compression method ([06d47ded](https://github.com/dracutdevs/dracut/commit/06d47ded679231e1370cc655c1df408fc865baac))
    *  drop pointless check for module compression method ([586d3e76](https://github.com/dracutdevs/dracut/commit/586d3e7664c00bf144becfa69dde2dbab8711d51))
    *  change misspelled variable name ([acfd97a9](https://github.com/dracutdevs/dracut/commit/acfd97a94385c33cd6cef4e5a37f233ea4081288))
    *  remove wrong $ in loop sequence ([f1245b5b](https://github.com/dracutdevs/dracut/commit/f1245b5bc13a98ef0dcc679dcef6148214e09503))
    *  handle symlinks appropriately while using '-i' option ([c7fbc0c8](https://github.com/dracutdevs/dracut/commit/c7fbc0c8901917baf0d1f0822568e65c6ec00d18))
    *  handle '-i' option to include files beginning with '.' ([f1138012](https://github.com/dracutdevs/dracut/commit/f1138012c9dc44e6614466c0a8e929fc55e4a5dd))
* **drm:**  add privacy screen modules to the initrd ([14d97a6a](https://github.com/dracutdevs/dracut/commit/14d97a6a28c6172340c47c89374358aaf4e2629d))
* **fedora.conf.example:**  rename misspelled variable ([9371dcab](https://github.com/dracutdevs/dracut/commit/9371dcaba3c58377428eee44bd702fae7b2ab20e))
* **fido2:**  add a missing library ([4753738b](https://github.com/dracutdevs/dracut/commit/4753738b62d958955f50fb077ea21c56a8d23dc3))
* **fips:**
    *  missing sourcing of dracut-lib ([857b17f0](https://github.com/dracutdevs/dracut/commit/857b17f090bdf575292f0bd6f5e8e3d753f6b426))
    *  add and remove local variables ([e8121bfd](https://github.com/dracutdevs/dracut/commit/e8121bfddda34e20db889a74d4ac6259ed182aea))
    *  wrong error message ([7f10c483](https://github.com/dracutdevs/dracut/commit/7f10c483b6abcc8be42cf246bbdade264be68228))
    *  handle s390x OSTree systems ([78557f05](https://github.com/dracutdevs/dracut/commit/78557f05a69fe718a97df85d2ed741ce10d3f806))
* **fips.sh:**  repsect rd.fips.skipkernel ([5789abcb](https://github.com/dracutdevs/dracut/commit/5789abcbe05f30d556086590b786c4857d025d9d))
* **img-lib:**  install rmdir ([51ce8893](https://github.com/dracutdevs/dracut/commit/51ce8893d981e90640123a7dcc3e4f3621e7d819))
* **install:**
    *  segfault on popen error ([5c2f72f1](https://github.com/dracutdevs/dracut/commit/5c2f72f152ec319a8001d1ff0bfd1f81a9130b04))
    *  extend hwcaps library handling to libraries under glibc-hwcaps/ ([10ed204f](https://github.com/dracutdevs/dracut/commit/10ed204f873f454dcd15ffcc82dc3a1c781c1514))
    *  use size_t to avoid -Wsign-compare warning ([55468a2d](https://github.com/dracutdevs/dracut/commit/55468a2d40182de4cce5ba4ecd5dcd96be03bd4d))
    *  improve gettid definition ([ef0f848a](https://github.com/dracutdevs/dracut/commit/ef0f848a67fdd0a0dab135acbd1cd7fa0179a95c))
    *  validate return values log.c ([19537f89](https://github.com/dracutdevs/dracut/commit/19537f8943ac4106c6d4ab0e00a48a8c0a9a0519))
    *  rectify unused function args in log.c ([b5cf7ec7](https://github.com/dracutdevs/dracut/commit/b5cf7ec784335ec561e379f8e78f48019a344ac0))
    *  use wrapper for asprintf ([e2a61595](https://github.com/dracutdevs/dracut/commit/e2a61595d2c91202ff4ea69937064cd2c0d1f336))
    *  use unsigned int instead of unsigned ([74a41799](https://github.com/dracutdevs/dracut/commit/74a417994840f7a6119e2dee57f9a3bb4d84998b))
    *  reduce cppcheck warnings ([b0bf8187](https://github.com/dracutdevs/dracut/commit/b0bf8187d5cc51d5576d8d70a81677d7c9741b37))
    *  add a missing ret value assignment ([6a444261](https://github.com/dracutdevs/dracut/commit/6a44426162d5b1b7084b17f921799863d353f847))
* **integrity:**  add support for loading multiple EVM x509 certs ([9da76af8](https://github.com/dracutdevs/dracut/commit/9da76af8e7f0f7a939b2ee44f0b4a5ce0bdd3b0b))
* **iscsi:**  add support for the new iscsiadm "no-wait" (-W) command ([7374943a](https://github.com/dracutdevs/dracut/commit/7374943ae3d063f0142c969b132c4156030fda8b))
* **kernel-modules:**
    *  add mailbox drivers for arm ([0e80ff72](https://github.com/dracutdevs/dracut/commit/0e80ff72e01d28e7e92d3adbf98ec40bdbdc37fe))
    *  detect block device's hardware driver ([c86f4d28](https://github.com/dracutdevs/dracut/commit/c86f4d286000d1e76fd405560b4114537e2cbbff))
    *  add blk_mq_alloc_disk and blk_cleanup_disk to blockfuncs ([b292ce72](https://github.com/dracutdevs/dracut/commit/b292ce7295f18192124e64e5ec31161d09492160))
    *  add more modules on RISC-V ([3cc9f1c1](https://github.com/dracutdevs/dracut/commit/3cc9f1c10c67dcdb5254e0eb69f19e9ab22abf20))
    *  add isp1760 USB controller ([15398458](https://github.com/dracutdevs/dracut/commit/15398458685d376fef56b1bf6fe09ae7c68324c1))
    *  add Type-C USB drivers for generic initrd ([a1287c62](https://github.com/dracutdevs/dracut/commit/a1287c627f28b16b1b066b7c256549b832bd98de))
* **kernel-modules-extra:**  handle zstd module extension ([b3d2dcb7](https://github.com/dracutdevs/dracut/commit/b3d2dcb71e7af8f605f5f66041ed3c801333e5f1))
* **lvm:**
    *  restore setting LVM_MD_PV_ACTIVATED ([164e5ebb](https://github.com/dracutdevs/dracut/commit/164e5ebb1199ea3e3d641ce402d8257f0055a529))
    *  replace --partial option ([97543cca](https://github.com/dracutdevs/dracut/commit/97543cca48dfde849396f11c83f9c320e1b91c46))
* **man:**  default value of rd.retry was increased to 180 seconds ([4855242c](https://github.com/dracutdevs/dracut/commit/4855242ce5cb586afd2eebd91df57ce1d28ae6b5))
* **mdraid:**  allow UUID comparison for more than one UUID ([d364ce83](https://github.com/dracutdevs/dracut/commit/d364ce8334fef96f48492bd0fb3b7deac37bbb66))
* **memstrack:**  drop bash runtime requirement ([35822f39](https://github.com/dracutdevs/dracut/commit/35822f39970b369301e0ff54436d5714dd996896))
* **mksh:**  requires printf ([f806a628](https://github.com/dracutdevs/dracut/commit/f806a628aa9aec548e425e81b6ea4ab6f5db26f6))
* **multipath:**
    *  check if mpathconf is available ([4318533e](https://github.com/dracutdevs/dracut/commit/4318533e1493bfab622b64efc1b799426c812c26))
    *  drop ExecStop= setting from service unit ([9491e599](https://github.com/dracutdevs/dracut/commit/9491e599282d0d6bb12063eddbd192c0d2ce8acf))
    *  get config. dir from configuration ([2e3c5444](https://github.com/dracutdevs/dracut/commit/2e3c5444d271cb8f05955858b8fdc367c4ea5c48))
* **multipathd.service:**
    *  drop dependencies on iscsi and iscsid ([6246da40](https://github.com/dracutdevs/dracut/commit/6246da400fa7f527a1ff1c620bf85ac9f6644508))
    *  adapt to upstream multipath-tools unit file ([a247d2bc](https://github.com/dracutdevs/dracut/commit/a247d2bc0d4c6d37a2ea4f3da98dd7902bb37385))
    *  remove dependency on systemd-udev-settle ([371b338a](https://github.com/dracutdevs/dracut/commit/371b338a5f19d40ff4c3216dc0f27f9a00cf4e22))
* **network:**
    *  consistent use of "$gw" for gateway ([3f2c76bb](https://github.com/dracutdevs/dracut/commit/3f2c76bb1456941a28d3333569d2bf18f8624617))
    *  wrong test of wicked unit ([22e68307](https://github.com/dracutdevs/dracut/commit/22e683077a686b592da55e1d247b31f65c95d481))
    *  add errors and warnings when network interface does not exist ([79389352](https://github.com/dracutdevs/dracut/commit/7938935267dd8824f074adf84c219340ad4c8db6))
* **network-manager:**
    *  skip non-directories in /sys/class/net ([d9c3c774](https://github.com/dracutdevs/dracut/commit/d9c3c77437d91d7d66369a3ef701ffc5e501346d))
    *  disable tty output if the console is not usable ([f6e6be24](https://github.com/dracutdevs/dracut/commit/f6e6be245d0cda14d90a0442b688c8dca1410a2e))
    *  show output on console only with rd.debug enabled ([e07b7ad0](https://github.com/dracutdevs/dracut/commit/e07b7ad0e7f5dbb8024336f3075610b3b74ffb2e))
    *  write DHCP filename option to dhcpopts file ([38320fce](https://github.com/dracutdevs/dracut/commit/38320fce56a8d83b79d6c970c491a454ba9de213))
    *  check for nm-initrd-generator in both /usr/{libexec,lib} ([5ee7e249](https://github.com/dracutdevs/dracut/commit/5ee7e249b8cc74461122ccd7efe954b3402c23da))
    *  ensure safe content of /tmp/dhclient."$ifname".dhcpopts ([e509c638](https://github.com/dracutdevs/dracut/commit/e509c638e68a8e3cae446d1a4f9f86e3aa6e7a99))
    *  include nm-daemon-helper binary ([0e590531](https://github.com/dracutdevs/dracut/commit/0e5905315e92dfc095f543fd73db6190db533217))
    *  don't pull in systemd-udev-settle ([a0f12fb6](https://github.com/dracutdevs/dracut/commit/a0f12fb6a09b09f35ab28753d7c4461c10a8b562))
    *  support teaming under NM+systemd ([a97d2ced](https://github.com/dracutdevs/dracut/commit/a97d2cedcf65a9a2fbff2591171f0163c7d3cb46))
    *  pull in network.target in nm-initrd.service ([a97d6e2b](https://github.com/dracutdevs/dracut/commit/a97d6e2b13146783831b166ec5e8b33b29c514b0))
* **network-wicked:**  multiple path corrections ([d3b5bc17](https://github.com/dracutdevs/dracut/commit/d3b5bc17ebadfe8922d1144b3dfd5435d0ecc71a))
* **nvmf:**  validate_ip_conn ([655c65e6](https://github.com/dracutdevs/dracut/commit/655c65e6ced00e7a80c41e96c5f6fe108da07839))
* **qeth_rules:**  check the existence of /sys/devices/qeth/*/online beforehand ([6c71ba41](https://github.com/dracutdevs/dracut/commit/6c71ba4121ae64ccd13fefba68ca327ac623810f))
* **resume:**
    *  resume using /usr/lib64/suspend ([c4593734](https://github.com/dracutdevs/dracut/commit/c459373448d24760d15e22fde7c6f811c7891376))
    *  check for presence of /sys/power/resume ([0b977906](https://github.com/dracutdevs/dracut/commit/0b97790626bff3579755b38f78a9c524a075cfcc))
* **rootfs-block:**  make the base module dependency explicit ([3326e4c9](https://github.com/dracutdevs/dracut/commit/3326e4c957d0499495d9e91182fc574b960ace86))
* **s390_rules:**  drop collect installation ([f905c3a7](https://github.com/dracutdevs/dracut/commit/f905c3a72c975cf6006f266755cc91229132c739))
* **shutdown:**  be robust against forced shutdown ([b9ba3c8b](https://github.com/dracutdevs/dracut/commit/b9ba3c8bb8f0f1328cd1ffaa8dbf64585b28c474))
* **skipcpio:**
    *  calculate and use CPIO_MAGIC_LEN ([3fb8723c](https://github.com/dracutdevs/dracut/commit/3fb8723ce0066b4ba92f6dbfc4373a66d1f551c4))
    *  improve error checking ([f6d16b6b](https://github.com/dracutdevs/dracut/commit/f6d16b6bbd5b8b7ac238c3d2148bebf4e91140a2))
* **squash:**
    *  apply FIPS and libpthread workaround ([5ab18dee](https://github.com/dracutdevs/dracut/commit/5ab18dee996f0eeb2b0bfe354570e1b1af46d025))
    *  remove tailing '/' when installing ld.so.conf.d ([cbd85597](https://github.com/dracutdevs/dracut/commit/cbd85597e3ed6abf64ac17f431da5477eb5aefa0))
    *  keep ld cache under initdir ([dc21638c](https://github.com/dracutdevs/dracut/commit/dc21638c3f0acbb54417f3bfb6294ad5514bf2db))
    *  create relative symlinks ([a2b6be44](https://github.com/dracutdevs/dracut/commit/a2b6be44792b68218e3378a7d844b0f8527a4805))
* **systemd-sysusers:**
    *  use split systemd sysuser configs ([fec93bb2](https://github.com/dracutdevs/dracut/commit/fec93bb22181f80056b40231fca36c422248ade0))
    *  override systemd-sysusers.service ([dcbe23c1](https://github.com/dracutdevs/dracut/commit/dcbe23c14d13ca335ad327b7bb985071ca442f12))
* **tpm2-tss:**
    *  add a missing library ([c656b612](https://github.com/dracutdevs/dracut/commit/c656b612b101e4834e01f9841162e2629a7272f7))
    *  typo in depends() ([8b17105b](https://github.com/dracutdevs/dracut/commit/8b17105bed69ed90582a13d97d95ee19e6581365))
* **url-lib:**
    * SC2086: Double quote to prevent globbing and word splitting ([acb18869](https://github.com/dracutdevs/dracut/commit/acb18869e98687a3f8c172d7e7befaa5326cf67a))
    * SC2046: Quote this to prevent word splitting ([ec50cec3](https://github.com/dracutdevs/dracut/commit/ec50cec3bd9169410df409e077d0487c63c2a627))
    * improve ca-bundle detection ([e3bb1815](https://github.com/dracutdevs/dracut/commit/e3bb1815bbbff1a7e21b857d2ae32bc0410754d5))
    * make pre-pivot hook separetely per nfs mount ([2f091b17](https://github.com/dracutdevs/dracut/commit/2f091b17075f81ff490b05d3d566d736fc32f0be))
* **usrmount:**  do not empty _dev variable ([4afdcba2](https://github.com/dracutdevs/dracut/commit/4afdcba212793f136aea012b30dd7bdb5b641a5a))
* **zfcp_rules:**
    *  correct udev zfcp rules parsing ([59252668](https://github.com/dracutdevs/dracut/commit/5925266832042f9d17a3fb7a219b83118c5b16d6))
    *  remove collect based udev rule creators ([d40c49a8](https://github.com/dracutdevs/dracut/commit/d40c49a8dfe203be33af8ace5f0efd07a88856f4))

#### Features

* **Makefile:**  cargo wrapper for dracut-cpio build ([51d21c6b](https://github.com/dracutdevs/dracut/commit/51d21c6b37b0eb8566d18d665d0197ca4d68101c))
* **cpio:**
    *  add newc archive creation utility ([a9c67046](https://github.com/dracutdevs/dracut/commit/a9c67046431ccf5fd4f4c16c890695df388f0d38))
    *  add rust argument parsing library from crosvm ([94fc5026](https://github.com/dracutdevs/dracut/commit/94fc50262f5e6c28d92782dc231fbb6c61855954))
* **crypt:**
    *  check if pkcs11 module is needed in hostonly mode ([56f4fb6c](https://github.com/dracutdevs/dracut/commit/56f4fb6cb755327c77c32f8c414a4a0e64fc933c))
    *  check if fido2 module is needed in hostonly mode ([d5fd030c](https://github.com/dracutdevs/dracut/commit/d5fd030cc285730e1a1b9e0e78a1e1dc4daabfe0))
    *  check if tpm2-tss module is needed in hostonly mode ([5d990a00](https://github.com/dracutdevs/dracut/commit/5d990a004b5ae6863f2c9a633b184c07dd73563d))
* **dracut.sh:**
    *  add --aggresive-strip option ([67fc670a](https://github.com/dracutdevs/dracut/commit/67fc670a88ab6c97d22c6718082619c0cf850fc3))
    *  add "--enhanced-cpio" option for calling dracut-cpio ([afe4a6db](https://github.com/dracutdevs/dracut/commit/afe4a6dbb7df62982baab8212bba5d90010dfbac))
    *  check if target kernel has zstd support compiled in ([591118c5](https://github.com/dracutdevs/dracut/commit/591118c56da2bfcea060e3b7671bc87b23c0e44a))
* **fido2:**  introducing the fido2 module ([049973b7](https://github.com/dracutdevs/dracut/commit/049973b708298ea0ce1ac9c869b404f4c718eff3))
* **lvm:**
    *  only run lvchange for LV that is seen on devices ([1af46743](https://github.com/dracutdevs/dracut/commit/1af46743195422aaebcde5c508a5dd479eff51ea))
    *  use generated filter when none is set ([7ffc5e38](https://github.com/dracutdevs/dracut/commit/7ffc5e388bcce20785803825bdd260c3c854b34f))
    *  update lvm command options ([c0a54f29](https://github.com/dracutdevs/dracut/commit/c0a54f2993b1d3c2101202c274a41f925445d54b))
* **pcsc:**  introducing the pcsc module ([dcaff88a](https://github.com/dracutdevs/dracut/commit/dcaff88ac942042e3db0a2bbfc1c995ec0735f38))
* **pkcs11:**
    *  include the module in the spec file ([c5907f82](https://github.com/dracutdevs/dracut/commit/c5907f82d835d72e4dd7c473a86e872fce37d61e))
    *  introducing the pkcs11 module ([83ea8cf0](https://github.com/dracutdevs/dracut/commit/83ea8cf001a49356cf7814b3c08bdd1c4b4f2763))
* **spec:**  add systemd-integritysetup module ([fe8df024](https://github.com/dracutdevs/dracut/commit/fe8df0240a24b9d2d60a5b0b998f82b251ede849))
* **squash:**  install umount util ([563f5434](https://github.com/dracutdevs/dracut/commit/563f543424c66bf38e6cbd3f489655d45ad9b5c5))
* **systemd:**  enable support for systemd compiled with ASAN ([d502d2a8](https://github.com/dracutdevs/dracut/commit/d502d2a816ba8f8329b3d8616bd2a7e82a0ad21f))
* **systemd-integritysetup:**  introducing the systemd-integritysetup module ([33cf47a6](https://github.com/dracutdevs/dracut/commit/33cf47a60870cc290bd5b59c9cf87c54ad37051f))

#### Contributors

- Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
- David Disseldorp <ddiss@suse.de>
- Martin Wilck <mwilck@suse.de>
- Jóhann B. Guðmundsson <johannbg@gmail.com>
- Shreenidhi Shedi <sshedi@vmware.com>
- David Teigland <teigland@redhat.com>
- Beniamino Galvani <bgalvani@redhat.com>
- Thomas Blume <thomas.blume@suse.com>
- Kairui Song <kasong@redhat.com>
- Laszlo Gombos <laszlo.gombos@gmail.com>
- Renaud Métrich <rmetrich@redhat.com>
- Dusty Mabe <dusty@dustymabe.com>
- Masahiro Matsuya <mmatsuya@redhat.com>
- Alexander Wenzel <alexander.wenzel@qbeyond.de>
- Andre Russ <andre.russ@sap.com>
- Cornelius Hoffmann <coding@hoffmn.de>
- David Tardon <dtardon@redhat.com>
- Frantisek Sumsal <frantisek@sumsal.cz>
- Harald Hoyer <harald@profian.com>
- José María Fernández <josemariafg@gmail.com>
- Kairui Song <kasong@tencent.com>
- Peter Robinson <pbrobinson@fedoraproject.org>
- Pingfan Liu <piliu@redhat.com>
- Tony Asleson <tasleson@redhat.com>
- Zoltán Böszörményi <zboszor@gmail.com>
- Adrien Thierry <athierry@redhat.com>
- Alexander Tsoy <alexander@tsoy.me>
- Andreas Schwab <schwab@suse.de>
- Andrey Sokolov <keremet@altlinux.org>
- Brandon Sloane <btsloane@verizon.net>
- Charles Rose <charles.rose@dell.com>
- Coiby Xu <coxu@redhat.com>
- Dan Horák <dhorak@redhat.com>
- Dirk Müller <dirk@dmllr.de>
- Glenn Morris <rgm@stanford.edu>
- Hans de Goede <hdegoede@redhat.com>
- Hari Bathini <hbathini@linux.ibm.com>
- Henrik Gombos <henrik99999@gmail.com>
- Jonathan Lebon <jonathan@jlebon.com>
- LinkTed <link.ted@mailbox.org>
- Lubomir Rintel <lkundrak@v3.sk>
- Luca BRUNO <luca.bruno@coreos.com>
- Lukas Nykryn <lnykryn@redhat.com>
- Matthias Berndt <matthias_berndt@gmx.de>
- Mike Gilbert <floppym@gentoo.org>
- Pavel Valena <pvalena@redhat.com>
- Stefan Berger <stefanb@linux.ibm.com>
- Thomas Haller <thaller@redhat.com>
- Tomasz Paweł Gajc <tpgxyz@gmail.com>
- Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl>
- joshuacov1 <joshuacov@gmail.com>
- lapseofreason <lapseofreason0@gmail.com>

dracut-055
==========

#### Bug Fixes

* **base:**
    *  add missing `str_replace` to `dracut-dev-lib.sh` ([148e420b](https://github.com/dracutdevs/dracut/commit/148e420be5b5809aa8d5033f47477573bbbf3e60))
    *  split out `dracut-dev-lib.sh` ([c08bc810](https://github.com/dracutdevs/dracut/commit/c08bc8109d4c43beacfa4bcdc20a356102da6d02))
* **bash:**  minor cleanups ([9355cb8e](https://github.com/dracutdevs/dracut/commit/9355cb8ea5024533210067373657dc337d63ecb9))
* **dash:**  minor cleanups ([f4ea5f87](https://github.com/dracutdevs/dracut/commit/f4ea5f8734c4636f7d6db78da76e9525beb9a0ac))
* **dracut:**  pipe hardlink output to `dinfo` ([0a6007bf](https://github.com/dracutdevs/dracut/commit/0a6007bf4f472565d2c0c205a56edea7ba3e3bc3))
* **dracut-functions:**  get_maj_min without get_maj_min_cache_file set ([a277a5fc](https://github.com/dracutdevs/dracut/commit/a277a5fc7acc0a9e8d853f09671495f9d27645c1))
* **dracut-util:**  print error message with trailing newline ([b9b6f0ee](https://github.com/dracutdevs/dracut/commit/b9b6f0ee5b859a562e46a8c4e0dee0261fabf74d))
* **fs-lib:**  install fsck utilities ([12beeac7](https://github.com/dracutdevs/dracut/commit/12beeac741e4429146a674ef4ea9aa0bac10364b))
* **install:**
    *  configure logging earlier ([5eb24aa2](https://github.com/dracutdevs/dracut/commit/5eb24aa21d3ee639f869c2e363b3fb0b98be552b))
    *  sane default --kerneldir ([c1ab3613](https://github.com/dracutdevs/dracut/commit/c1ab36139d416e580e768c29f2addf7ccbc2c612), closes [#1505](https://github.com/dracutdevs/dracut/issues/1505))
* **integrity:**  require ALLOW_METADATA_WRITES to come from EVM config file ([b12d91c4](https://github.com/dracutdevs/dracut/commit/b12d91c431220488fecf7b4be82427e3560560cb))
* **mksh:**  minor cleanups ([6c673298](https://github.com/dracutdevs/dracut/commit/6c673298f36990665467564e6114c9ca2530f584))
* **squash:**  don't mount the mount points if already mounted ([636d6df3](https://github.com/dracutdevs/dracut/commit/636d6df3134dde1dac72241937724bc59deb9303))
* **warpclock:**  minor cleanups ([7d205598](https://github.com/dracutdevs/dracut/commit/7d205598c6a500b58b4d328e824d0446276f7ced))

#### Features

* **dracut.sh:**  detect running in a container ([7275c6f6](https://github.com/dracutdevs/dracut/commit/7275c6f6a0f6808cd939ea5bdf1244c7bd13ba44))
* **install:**  add default value for --firmwaredirs ([4cb086fa](https://github.com/dracutdevs/dracut/commit/4cb086fa2995799b95c0b25bc9a0cf72ba3868ea))

#### Contributors

- Harald Hoyer <harald@redhat.com>
- Jóhann B. Guðmundsson <johannbg@gmail.com>
- Marcos Mello <marcosfrm@gmail.com>
- Kairui Song <kasong@redhat.com>
- Lars Wendler <polynomial-c@gentoo.org>
- Stefan Berger <stefanb@linux.ibm.com>
- Tomasz Paweł Gajc <tpgxyz@gmail.com>

dracut-054
==========

With this release dracut has undergone a major overhaul.

A lot of systemd related modules have been added.

The integration test suite has finally ironed out the flaky behaviour due to the parallel device probing of the kernel,
which bit sometimes in the non-kvm github CI. So, if you see any `/dev/sda` in a setup script with more than two hard drives,
chances are, that the script works on the wrong disk. Same goes for network interfaces.

This release is also fully `shellcheck`'ed with `ShellCheck-0.7.2` and indented with `shfmt` and `astyle`.

The dracut project builds test containers every day for:
* `opensuse/tumbleweed-dnf:latest`
* `archlinux:latest`
* `fedora:rawhide`
* `fedora:latest`
* `fedora:33`

These containers can easily be used to run the integration tests locally without root permissions via `podman`.
We hope this serves as a blueprint for your distribution's CI process.

More information can be found in [docs/HACKING.md](https://github.com/dracutdevs/dracut/blob/master/HACKING.md).

#### Bug Fixes

*   make testsuite pass on OpenSuse and Arch ([8b2afb08](https://github.com/dracutdevs/dracut/commit/8b2afb08baea7fc6e15ece94e287dcc4a008bcc4))
*   cope with distributions with `/usr/etc` files ([3ad3b3a4](https://github.com/dracutdevs/dracut/commit/3ad3b3a40d419c4386b2924f6ac25ab0c355d131))
*   deprecate gummiboot ([5c94cf41](https://github.com/dracutdevs/dracut/commit/5c94cf41e8937b6fbb72c96bc54c84fdf224c711))
*   set vimrc and emacs indention according to .editorconfig ([9012f399](https://github.com/dracutdevs/dracut/commit/9012f3996b1e5f0788f8e80dfdd5c9ab0636c355))
*   correctly handle kernel parameters ([501d82f7](https://github.com/dracutdevs/dracut/commit/501d82f79675a6bf9b37e8250152515863a80236))
*   remove dracut.pc on `make clean` ([d643156d](https://github.com/dracutdevs/dracut/commit/d643156d561d3aca816d75e403149db073617292))
*   honor KVERSION environment in the Makefile ([d8a454a5](https://github.com/dracutdevs/dracut/commit/d8a454a537c6de95033dec7d83c622fdc46c2a4f))
*   always use mkdir -p ([9cf7b1c5](https://github.com/dracutdevs/dracut/commit/9cf7b1c529442d5abd6eaec4399d4ee77b95145e))
* **dracut.sh:**
    *  prevent symbolic links containing `//` ([de0c0872](https://github.com/dracutdevs/dracut/commit/de0c0872fc858fa9ca952f79ea9f00be17c37a4c))
    *  adding missing globalvars for udev ([f35d479d](https://github.com/dracutdevs/dracut/commit/f35d479d2b718da54886a66d3b7af2132215f80a))
    *  sysctl global variables ([3ca9aa1d](https://github.com/dracutdevs/dracut/commit/3ca9aa1d7b24b82e01d16613b86ec3be97c8a1bb))
    *  add global vars for modules-load ([ec4539c6](https://github.com/dracutdevs/dracut/commit/ec4539c6066edf25e52ed8e2d35c4be7ef39f729))
    *  omission is an addition to other omissions in conf files ([96c31333](https://github.com/dracutdevs/dracut/commit/96c313333d1a4f5e2c524a3a11c5b3aab24afc20))
    *  harden dracut against GZIP environment variable ([d8e47e20](https://github.com/dracutdevs/dracut/commit/d8e47e201af4646e2a82e11220ea9c993bd2ed48))
    *   add a missing tmpfilesconfdir global variable ([8849dd8d](https://github.com/dracutdevs/dracut/commit/8849dd8d1a74a46cb761c4d8041e4582d4686724))
    *   include `modules.builtin.alias` in the initramfs ([7f633747](https://github.com/dracutdevs/dracut/commit/7f6337471312486934f9592c1c7c05ed68694454))
    *   install all depmod relevant configuration files ([50a01dd4](https://github.com/dracutdevs/dracut/commit/50a01dd4b28471c0dfa810a705e219963bd5ec3c))
    *   add `modules.builtin.modinfo` to the initramfs ([87c4c178](https://github.com/dracutdevs/dracut/commit/87c4c17850e8bb982f6c07a6d3f58124bb2875de))
    *   search for btrfs devices from actual mount poiont ([3fdc734a](https://github.com/dracutdevs/dracut/commit/3fdc734a5cc8c0b94c1da49439181d540c8a5c43))
* **dracut-functions.sh:**
    *  implement a cache for get_maj_min ([c3bb9d18](https://github.com/dracutdevs/dracut/commit/c3bb9d18dceed7db6d16f9c2a7f682c5934099d7))
    *  word splitting issue for sed in get_ucode_file ([122657b2](https://github.com/dracutdevs/dracut/commit/122657b2fedf13991597830cca4d4ddbc8038233))
* **dracut-logger.sh:**  double dash trigger unknown logger warnings during run ([4fbccde5](https://github.com/dracutdevs/dracut/commit/4fbccde50456f513d388cdfd858018cd889890dc))
* **dracut-install:**
    *  handle $LIB in ldd output parsing ([d1a36d3d](https://github.com/dracutdevs/dracut/commit/d1a36d3d80b0ed71ee814659e18a020c53cee05e))
    *  handle builtin modules ([2536a9ea](https://github.com/dracutdevs/dracut/commit/2536a9eaffbc9cc14c85579a2f537d3f3a1d5659))
* **base:**
    *  suppress calls to getarg in build phase ([6feaaabc](https://github.com/dracutdevs/dracut/commit/6feaaabc221ffbf79f652cbee3eea58f02449c50))
    *  source hooks without exec ([8059bcb2](https://github.com/dracutdevs/dracut/commit/8059bcb2c8df4d60cc2f548d3c53db25d815a7be))
    *  wait_for_dev quote shell variables ([b800edd6](https://github.com/dracutdevs/dracut/commit/b800edd69817b5e46d5f240b96d3b3648267ea21))
    *  adding crc32c for ext3 ([61f45643](https://github.com/dracutdevs/dracut/commit/61f456435879f084a1bf2c8885eaf37070035abf))
* **crypt:**
    *  install all crypto modules in the generic initrd ([10f9e569](https://github.com/dracutdevs/dracut/commit/10f9e569c52654ff54678a626a0f5dd14233716d))
    *  include cryptsetups tmpfile ([a4cc1964](https://github.com/dracutdevs/dracut/commit/a4cc196467e45f093fab7876c1c6b40798058920))
* **crypt-gpg:**
    *  cope with different scdaemon location ([44fd1c13](https://github.com/dracutdevs/dracut/commit/44fd1c13555f2e12bb566c246948629ada27d14d))
* **dbus-broker:**
    *  enable the service ([df1e5f06](https://github.com/dracutdevs/dracut/commit/df1e5f06a5449dcec6749baf742eac6eb1f0aa53))
* **dbus-daemon:**
    *  only error out in install() ([ae4fbb3d](https://github.com/dracutdevs/dracut/commit/ae4fbb3db4136e6e03a1c74d05ecc2a73b916401))
* **dracut-systemd:**
    *  don't refuse root=tmpfs when systemd is used ([a96900a8](https://github.com/dracutdevs/dracut/commit/a96900a82c3a8ec1ed2c6b2cc8862f912093fa0c))
* **examples:**  remove the examples directory and reference to it ([b37c90c8](https://github.com/dracutdevs/dracut/commit/b37c90c8e00155a1f31237ae6cf91a81677c4df5))
* **fips:**
    *  add dh and ecdh ciphers ([543b8014](https://github.com/dracutdevs/dracut/commit/543b8014fc10fc6a92ba83db0dfc994fc1d2129b))
    *  remove old udev version requirements ([be30d987](https://github.com/dracutdevs/dracut/commit/be30d98751cff4ace660215305e2468943a45754))
* **i18n:**
    *  skip if data is missing ([651fe01e](https://github.com/dracutdevs/dracut/commit/651fe01e7937d86bbd471d9621581bed44f23dfa))
* **img-lib:**
    *  ignored null byte in input ([85eb9680](https://github.com/dracutdevs/dracut/commit/85eb96802cb82ec179bd3bc429b0dad2518946c5))
* **integrity:**
    *  properly set up EVM when using an x509 cert ([4bdd7eb2](https://github.com/dracutdevs/dracut/commit/4bdd7eb23a8187c3f19797e47eee8c672cea33ae))
* **iscsi:**
    *  replace sed call with bash internals ([66b920c6](https://github.com/dracutdevs/dracut/commit/66b920c65143f4cac80385a51704ae9483305569))
    *  add iscsid.service requirements ([bb6770f1](https://github.com/dracutdevs/dracut/commit/bb6770f1a413bdc7fd570b260ee28ace1255a195))
    *  only rely on socket activiation ([0eb87d78](https://github.com/dracutdevs/dracut/commit/0eb87d78108aae9aa4692f1edfb33ded50e26409))
* **kernel-modules:**
    *  optionally add /usr/lib/modules.d to initramfs ([92e6a8f8](https://github.com/dracutdevs/dracut/commit/92e6a8f87914322994387e559cf2a00b1760b301))
    *  add watchdog drivers for generic initrd ([3a60c036](https://github.com/dracutdevs/dracut/commit/3a60c036db7caccda95475d33c8d4ce1f615d2c8))
* **mdraid:**
    *  remove dependency statements ([86b75634](https://github.com/dracutdevs/dracut/commit/86b756346a6b7c5cb5f6fda4d12e2a58b6144e40))
* **memstrack:**
    *  correct dependencies ([c2ecc4d1](https://github.com/dracutdevs/dracut/commit/c2ecc4d131876383b47820a2e8d1a6f8a11716d9))
* **multipath:**
    *  stop multipath before udev db cleanup ([3c244c7c](https://github.com/dracutdevs/dracut/commit/3c244c7ca3555b526883dc20104c469b39085cbe))
    *  revise multipathd-stop ([7b8c78ff](https://github.com/dracutdevs/dracut/commit/7b8c78ff43a1f8e3690969e980d3d9d1dcb00c87))
* **nbd:**
    *  assume nbd version >= 3.8 ([6209edeb](https://github.com/dracutdevs/dracut/commit/6209edeb5c7783d94867829bf052aa53c78a1efe))
    *  remove old udev version requirements ([fd15dbad](https://github.com/dracutdevs/dracut/commit/fd15dbad6ebad86a3753a03f98706010f3e36cf7))
    *  make nbd work again with systemd ([77906443](https://github.com/dracutdevs/dracut/commit/7790644362622097aa69107920fd26b688c855d3))
* **network:**
    *  use wicked unit instead of find_binary ([57eefcf7](https://github.com/dracutdevs/dracut/commit/57eefcf70587f06b8874a3b3cf31e9ab70c03227))
    *  user variable for sdnetworkd instead of path ([4982e16d](https://github.com/dracutdevs/dracut/commit/4982e16dd53dcbbcfbd3a6b59013a0d6f893f840))
    *  correct regression in iface_has_carrier ([36af0518](https://github.com/dracutdevs/dracut/commit/36af0518b3fe59442de206c24bbe03be6fc17095))
* **network-legacy:**
    *  add missing options to dhclient.conf ([abfd547a](https://github.com/dracutdevs/dracut/commit/abfd547a85230a4520df65280aaf195f319df464))
    *  silence getargs ([60a34d8b](https://github.com/dracutdevs/dracut/commit/60a34d8b11dd50b2cd4e0e2208bd7c5e0fc48b71))
* **network-manager:**
    *  cope with distributions not using `libexec` ([22d6863e](https://github.com/dracutdevs/dracut/commit/22d6863ef1b2eb2a22264f2bfdb2b9329ab5dfdb))
    *  set timeout via command line option ([8a51ee1f](https://github.com/dracutdevs/dracut/commit/8a51ee1fa61bd3da342be53e35730837afd2caad))
    *  run after dracut-cmdline ([4d03404f](https://github.com/dracutdevs/dracut/commit/4d03404f499064b354a58223895cc47dbb461da5))
    *  create /run directories ([49b61496](https://github.com/dracutdevs/dracut/commit/49b614961dc8684f8512febbf80da489909e4b7f))
    *  use /run/NetworkManager/initrd/neednet in initqueue ([6a37c6f6](https://github.com/dracutdevs/dracut/commit/6a37c6f6302f950df608db3fd45acf9342ee3de2))
    *  only run NetworkManager if rd.neednet=1 ([ac0e8f7d](https://github.com/dracutdevs/dracut/commit/ac0e8f7dcc81432311906c3fca0d4211f6a2f68c))
    *  nm-run.service: don't kill forked processes ([1f21fac6](https://github.com/dracutdevs/dracut/commit/1f21fac646daa46cbe184ef8ff7705842f06ba15))
    *  no default deps for nm-run.service ([ba4bcf5f](https://github.com/dracutdevs/dracut/commit/ba4bcf5f4f11ad624c647ddf4f566997186135e7))
    *  nm-lib.sh does not require bash ([3402142e](https://github.com/dracutdevs/dracut/commit/3402142e344298c8f20fc52a2b064344788f1668))
* **squash:**
    *  post install should be the last step before stripping ([8c8aecdc](https://github.com/dracutdevs/dracut/commit/8c8aecdc63c9389038e78ee712d4809e49add5e1))
* **systemd:**
    *  include all nss libraries ([b3bbf5fb](https://github.com/dracutdevs/dracut/commit/b3bbf5fb6a95cfb69272da0711b5c5e0c6621de9))
    *  include hosts and nsswitch.conf in hostonly mode ([5912f4fb](https://github.com/dracutdevs/dracut/commit/5912f4fbc036cc36b9507c16dddef1ded1556572))
    *  remove old systemd version requirements ([fc53987b](https://github.com/dracutdevs/dracut/commit/fc53987bec1bc71b054d99072f62c1770a44bcca))
* **systemd-hostnamed:**  extra quote ([2aa65234](https://github.com/dracutdevs/dracut/commit/2aa652349ca83198581cccb516a241a8d0e1b4d9))
* **systemd-modules:**  remove dependency on systemd meta module ([afef4557](https://github.com/dracutdevs/dracut/commit/afef455718db69cff3797ca1a6d8bfebd2e86ab3))
* **systemd-modules-load:**
    *  misc repairs ([782ac8f1](https://github.com/dracutdevs/dracut/commit/782ac8f1f6b68edfe59630e9e4ac1673636f3a5e))
* **systemd-networkd:**
    *  make systemd-networkd a proper network provider ([ea779750](https://github.com/dracutdevs/dracut/commit/ea779750c371102c04252b48f1b7d9c7ece7cf93), closes [#737](https://github.com/dracutdevs/dracut/issues/737))
* **systemd-resolved:**  remove nss libraries ([12bef83c](https://github.com/dracutdevs/dracut/commit/12bef83cdaf329e3ee2cc1f282bd9c128ec0fc56))
* **systemd-sysctl:**
    *  sysctl global variables ([02acedd0](https://github.com/dracutdevs/dracut/commit/02acedd09eb7222eaaf0f5256f3ddec26d658360))
* **systemd-sysusers:**
    *  misc fixes and cleanup ([7359ba8a](https://github.com/dracutdevs/dracut/commit/7359ba8acab2652cfff6b845f84a936cdec30f9d))
* **systemd-udev:**  use global vars instead of fixed path ([fd883a58](https://github.com/dracutdevs/dracut/commit/fd883a58d1360f0c6c32f64462fafdd7a54af1ee))
* **systemd-udevd:**  add udev id program files ([562cb77b](https://github.com/dracutdevs/dracut/commit/562cb77b5a28e3f31bc6d327c7712fba661e9a27))
* **systemd-verity:**
    *  incorrect reference to cryptsetup target ([ba92d1fc](https://github.com/dracutdevs/dracut/commit/ba92d1fcad68758004d7b1102fe1905c0f25e63e))
    *  re-naming module to veritysetup ([0267f3c3](https://github.com/dracutdevs/dracut/commit/0267f3c3554efd8f027afaf462347167402f5d6c))
* **tpm2-tss:**  add tpm2 requirement ([8f99fada](https://github.com/dracutdevs/dracut/commit/8f99fadabea8f279a9fe28473dba424eb38f8d60))
* **udev-rules:**
    *  remove sourcing of network link files ([69f4e7cd](https://github.com/dracutdevs/dracut/commit/69f4e7cdc3f7da24e40496b0b2f0f5022cc3376d))
    *  add btrfs udev rules by default ([567c4557](https://github.com/dracutdevs/dracut/commit/567c4557537fe7f477f0f54237df00ebc79e56be))
* **url-lib:**
    *  fix passing args ([5f6be515](https://github.com/dracutdevs/dracut/commit/5f6be51595eab878314d031d9bfebe844b639302))
* **zipl:**
    *  don't depend on grub2 ([6b499ec1](https://github.com/dracutdevs/dracut/commit/6b499ec14b3ff35d5298617b436b64563a2d8c2f))

#### Performance

*   disable initrd compression when squash module is enabled ([7c0bc0b2](https://github.com/dracutdevs/dracut/commit/7c0bc0b2fd167da42035020dae49af94844f053c))

#### Features

*   support ZSTD-compressed kernel modules ([ce9af251](https://github.com/dracutdevs/dracut/commit/ce9af251af5fca08ea206ef980005853a4dac36e))
*   also restore the initramfs from /lib/modules ([33e27fab](https://github.com/dracutdevs/dracut/commit/33e27fab59db60b1ca05a0c5b8a51fccb98578e5))
*   extend Makefile indent target ([e0a0fa61](https://github.com/dracutdevs/dracut/commit/e0a0fa61749152fd5bc837770a02cf22d7e02d40))
*   customize .editorconfig according to shfmt ([1f621aba](https://github.com/dracutdevs/dracut/commit/1f621aba3728a621b83b3b697eae6caadae9d287))
*   squash module follow --compress option ([5d05ffbd](https://github.com/dracutdevs/dracut/commit/5d05ffbd87bc27e27f517ebc3454d50729c687e6))
* **bluetooth:**  implement bluetooth support in initrd ([64ee2a53](https://github.com/dracutdevs/dracut/commit/64ee2a53864576fbedabe6b18fb9aae01b999199))
* **btrfs:**  add 64-btrfs-dm.rules rules ([d4caa86a](https://github.com/dracutdevs/dracut/commit/d4caa86aba35b51dc1adda3ee3a5bae677420082))
* **mkinitrd:**  remove mkinitrd ([43df4ee2](https://github.com/dracutdevs/dracut/commit/43df4ee274e7135aff87868bf3bf2fbab47aa8b4))
* **nbd:**  support ipv6 link local nbds ([b12f8188](https://github.com/dracutdevs/dracut/commit/b12f8188a4ffac312694ebd48a5c99ba885e6467))
* **network-manager:**  run as daemon with D-Bus ([112f03f9](https://github.com/dracutdevs/dracut/commit/112f03f9e225a790cbc6378c70773c6af5e7ee34))
* **qemu:**  include the virtio_mem kernel module ([f3dcb606](https://github.com/dracutdevs/dracut/commit/f3dcb60619671f2d353caaa42d38207172c8b3ba))
* **skipcpio:**  speed up and harden skipcpio ([63033495](https://github.com/dracutdevs/dracut/commit/630334950c9a7a714fdf31b6ff545d804b5df2f2))
* **squash:**
    *  use busybox for early setup if available ([90f269f6](https://github.com/dracutdevs/dracut/commit/90f269f6afe409925bad86f0bd7e9322ad9b4fb0))
    *  install and depmod modules seperately ([5a18b24a](https://github.com/dracutdevs/dracut/commit/5a18b24a8b9c20c98f711963ce5407ceb2f3d57b))
* **systemd-ac-power:**  introducing the systemd-ac-power module ([e7407230](https://github.com/dracutdevs/dracut/commit/e74072306958262f22a9ecf10b928647ebdacf8f))
* **systemd-hostnamed:**  introducing the systemd-hostnamed module ([bf273e3e](https://github.com/dracutdevs/dracut/commit/bf273e3e8632faff68fe19f9d7d7cc42e5a7c480))
* **systemd-initrd:**  add initrd-usr-fs.target ([5eb73610](https://github.com/dracutdevs/dracut/commit/5eb736103d06197f37283bc27815c050adec81ea))
* **systemd-journald:**  introducing the systemd-journald module ([3697891b](https://github.com/dracutdevs/dracut/commit/3697891b754493ecd6b19dbf279701bad3460fcd))
* **systemd-ldconfig:**  introducing the systemd-ldconfig module ([563c434e](https://github.com/dracutdevs/dracut/commit/563c434ecba68c628344c1a684f656cdd8f9f214))
* **systemd-network-management:**  introducing systemd-network-management module ([e942d86c](https://github.com/dracutdevs/dracut/commit/e942d86c9ddad19f9307d58cb2d99169f6e94edb))
* **systemd-resolved:**  introducing the systemd-resolved module ([b7d3caef](https://github.com/dracutdevs/dracut/commit/b7d3caef6780305c553851169ca30b0b05b6ff31))
* **systemd-rfkill:**  introducing the systemd-rfkill module ([21536544](https://github.com/dracutdevs/dracut/commit/215365441e1042793d62c4c9e146be5916ed5aeb))
* **systemd-sysext:**  introducing the systemd-sysext module ([fc88af54](https://github.com/dracutdevs/dracut/commit/fc88af54134ec021be58465b52d1271453c30c55))
* **systemd-timedated:**  introducing the systemd-timedated module ([1c41cc90](https://github.com/dracutdevs/dracut/commit/1c41cc90c52636e03abdf6d0c4fa0f557b7eb449))
* **systemd-timesyncd:**  introducing the systemd-timesyncd module ([2257d545](https://github.com/dracutdevs/dracut/commit/2257d54583d24ca69d10b5e600b986d412a21714))
* **systemd-tmpfiles:**  introducing the systemd-tmpfiles module ([2b61be32](https://github.com/dracutdevs/dracut/commit/2b61be32b890e70b1fce45d984327c27302da9bc))
* **systemd-udevd:**  introducing the systemd-udevd module ([3534789c](https://github.com/dracutdevs/dracut/commit/3534789cc42331bc22cf44d26a1d04db4e010ad9))
* **systemd-verity:**  introducing the systemd-verity module ([3d4dea58](https://github.com/dracutdevs/dracut/commit/3d4dea58f9821e58841d5c738b9935193c680181))
* **tpm2-tss:**  introducing the tpm2-tss module ([8743b073](https://github.com/dracutdevs/dracut/commit/8743b0735692ab3f333815ba311cecdc29d45ecd))

#### Contributors

- Harald Hoyer <harald@redhat.com>
- Jóhann B. Guðmundsson <johannbg@gmail.com>
- Kairui Song <kasong@redhat.com>
- Dusty Mabe <dusty@dustymabe.com>
- Beniamino Galvani <bgalvani@redhat.com>
- Mikhail Novosyolov <m.novosyolov@rosalinux.ru>
- Renaud Métrich <rmetrich@redhat.com>
- Adam Alves <adamoa@gmail.com>
- Daniel Molkentin <daniel.molkentin@suse.com>
- David Hildenbrand <david@redhat.com>
- David Tardon <dtardon@redhat.com>
- Jaroslav Jindrak <dzejrou@gmail.com>
- Jonas Jelten <jj@sft.lol>
- Lennart Poettering <lennart@poettering.net>
- Lev Veyde <lveyde@redhat.com>
- Peter Robinson <pbrobinson@fedoraproject.org>
- Stefan Berger <stefanb@linux.ibm.com>
- Đoàn Trần Công Danh <congdanhqx@gmail.com>

dracut-053
==========

#### Bug Fixes

* **dracut.sh:**
  *  unfreeze /boot on exit ([d87ae137](https://github.com/dracutdevs/dracut/commit/d87ae13721d04a8a2192d896af224ac6965caf70))
  *  proper return code for inst_multiple in dracut-init.sh ([d437970c](https://github.com/dracutdevs/dracut/commit/d437970c013e3287de263a1e60a117b15239896c))
* **fcoe:**
  *  rename rd.nofcoe to rd.fcoe ([6f7823bc](https://github.com/dracutdevs/dracut/commit/6f7823bce65dd4b52497dbb94892b637fd06471a))
  *  rd.nofcoe=0 should disable fcoe ([805b46c2](https://github.com/dracutdevs/dracut/commit/805b46c2a81e04d69fc3af912942568516d05ee7))
* **i18n:**
  *  get rid of `eval` calls ([5387ed24](https://github.com/dracutdevs/dracut/commit/5387ed24c8b33da1214232d57ab1831e117aaba0))
  *  create the keyboard symlinks again ([9e1c7f3d](https://github.com/dracutdevs/dracut/commit/9e1c7f3deadd387adaa97b189593b4ba3d7c6d5a))
* **network-manager:**
  *  run as a service if systemd module is present ([c17c5b76](https://github.com/dracutdevs/dracut/commit/c17c5b7604c8d61dd1c00ee22d44c3a5d7d6dfee))
  *  rework how NM is started in debug mode ([34c73b33](https://github.com/dracutdevs/dracut/commit/34c73b339baa025dfd8916379c4d191be34a8af5))
* **drm:**  skip empty modalias files in drm module setup ([c3f24184](https://github.com/dracutdevs/dracut/commit/c3f241849de6434d063ef92e6880f6b0335c1800))


dracut-052
==========

#### Features

- **dracut:**
  - allow overriding the systemctl command for sysroot with `$SYSTEMCTL` for cross compilation
  - add additional global variables

     Variables like `dbusconfdir` or `systemdnetwork` are now exported
     to the individual modules as global variables. If they are not set
     in the distribution dracut config files, they are set via `pkg-config`

  - A `--no-uefi` option as been added to the CLI options to disable a default `uefi=yes`
    set by a configuration file.

- **kernel-modules:**  add modules from `drivers/memory` for arm
- **network-legacy:**  send dhcp in parallel on all devices via the `single-dhcp` option
- **dbus:**  introduce a meta module for dbus
- **dbus-broker:**  introduce the dbus-broker module
- **dbus-daemon:**  introduce the dbus-daemon module
- **systemd-ask-password:**  introduce the systemd-ask-password module
- **systemd-coredump:**  introduce the systemd-coredump module
- **systemd-modules-load:**  introduce the systemd-modules-load module
- **systemd-repart:**  introduce the systemd-repart module
- **systemd-sysctl:**  introduce the systemd-sysctl module
- **systemd-sysusers:** introduce the systemd-sysuser module

#### Bug Fixes

-   first round of shellcheck for all shell scripts
-   revise all module checks to not error out about missing dependencies
-   use the top-level `/efi` path to address the EFI partition
-   correct the squash quirk
-   use `find_binary` instead of other methods, because `find_binary` honors `dracutsysrootdir`
-   quote globbing in module-setup.sh for `inst_multiple`
-   move ldconfig after library workaround
-   do not set cmdline for uefi images unless asked
- **dracut:**  don't override `PATH`, if `dracutsysrootdir` is set
- **dracut-functions.sh:**  check kernel config from `dracutsysrootdir`
- **dracut-init.sh:**  make inst_libdir_file work with `dracutsysrootdir` set
- **dracut-install:**  allow globbing for multiple sources
- **06dbus:**
  -  do not hardcode path to dbus utils
  -  do not hardcode path to systemd unit
- **uefi**  use efivars fs over the deprecated sysfs entries
- **keyring**  adding shared keyring mode to systemd unit `dracut-pre-pivot.service`
- **35network-manager:**  avoid restarting NetworkManager
- **90kernel-modules:**  install generic crypto modules with hostonly unset
- **99squash:**  use kernel config instead of modprobe to check modules
- **dbus-daemon:**  use uid/gid from sysroot if `dracutsysrootdir` is set
- **kernel-modules:**  add reset controllers for arm
- **kernel-network-modules:**  also install modules from mdio subdirectory
- **mdraid:**
  -  remove the `offroot` option (long deprecated)
  -  add the grow continue service `mdadm-grow-continue`
- **network-legacy:**  silent the check for dhcp leaseinfo
- **network-manager:**  allow override network manager version
- **plymouth:**  install binaries with dependencies
- **shutdown:**  add timeout to umount calls
- **watchdog:**  fix dependencies in `module-setup.sh`

#### Contributors

- Harald Hoyer <harald@redhat.com>
- Jóhann B. Guðmundsson <johannbg@gmail.com>
- Zoltán Böszörményi <zboszor@pr.hu>
- Alexey Shabalin <shaba@altlinux.org>
- Daniel Molkentin <daniel.molkentin@suse.com>
- Luiz Angelo Daros de Luca <luizluca@gmail.com>
- Mariusz Tkaczyk <mariusz.tkaczyk@linux.intel.com>
- Alexander Tsoy <alexander@tsoy.me>
- Anjali Kulkarni <anjali.k.kulkarni@oracle.com>
- Beniamino Galvani <bgalvani@redhat.com>
- David Tardon <dtardon@redhat.com>
- Javier Martinez Canillas <javierm@redhat.com>
- Kairui Song <kasong@redhat.com>
- Lukas Nykryn <lnykryn@redhat.com>
- Matthew Thode <mthode@mthode.org>
- Nicolas Chauvet <kwizart@gmail.com>
- Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
- Ondrej Mosnacek <omosnace@redhat.com>
- Peter Levine <plevine457@gmail.com>
- Petr Pavlu <petr.pavlu@suse.com>
- Vladius25 <vkorol2509@icloud.com>
- Yang Liu <50459973+ly4096x@users.noreply.github.com>
- foopub <45460217+foopub@users.noreply.github.com>
- realtime-neil <neil@rtr.ai>


dracut-051
==========

dracut:
- allow running on a cross-compiled rootfs

  dracutsysrootdir is the root directory, file existence checks use it.

  DRACUT_LDCONFIG can override ldconfig with a different one that works
  on the sysroot with foreign binaries.

  DRACUT_LDD can override ldd with a different one that works
  with foreign binaries.

  DRACUT_TESTBIN can override /bin/sh. A cross-compiled sysroot
  may use symlinks that are valid only when running on the target
  so a real file must be provided that exist in the sysroot.

  DRACUT_INSTALL now supports debugging dracut-install in itself
  when run by dracut but without debugging the dracut scripts.
  E.g. DRACUT_INSTALL="valgrind dracut-install or
  DRACUT_INSTALL="dracut-install --debug".

  DRACUT_COMPRESS_BZIP2, DRACUT_COMPRESS_LBZIP2, DRACUT_COMPRESS_LZMA,
  DRACUT_COMPRESS_XZ, DRACUT_COMPRESS_GZIP, DRACUT_COMPRESS_PIGZ,
  DRACUT_COMPRESS_LZOP, DRACUT_COMPRESS_ZSTD, DRACUT_COMPRESS_LZ4,
  DRACUT_COMPRESS_CAT: All of the compression utilities may be
  overridden, to support the native binaries in non-standard places.

  DRACUT_ARCH overrides "uname -m".

  SYSTEMD_VERSION overrides "systemd --version".

  The dracut-install utility was overhauled to support sysroot via
  a new option -r and fixes for clang-analyze. It supports
  cross-compiler-ldd from
  https://gist.github.com/jerome-pouiller/c403786c1394f53f44a3b61214489e6f

  DRACUT_INSTALL_PATH was introduced so dracut-install can work with
  a different PATH. In a cross-compiled environment (e.g. Yocto), PATH
  points to natively built binaries that are not in the host's /bin,
  /usr/bin, etc. dracut-install still needs plain /bin and /usr/bin
  that are relative to the cross-compiled sysroot.

  DRACUT_INSTALL_LOG_TARGET and DRACUT_INSTALL_LOG_LEVEL were
  introduced so dracut-install can use different settings from
  DRACUT_LOG_TARGET and DRACUT_LOG_LEVEL.

- don't call fsfreeze on subvol of root file system
- Use TMPDIR (typically /run/user/$UID) if available
- dracut.sh: add check for invalid configuration files
  Emit a warning about possible misconfigured configuration files, where
  the spaces around values are missing for +=""
- dracut-functions: fix find_binary() to return full path
- dracut.sh: FIPS workaround for openssl-libs on Fedora/RHEL
- dracut.sh: fix early microcode detection logic
- dracut.sh: fix ia32 detection for uefi executables
- dracut.sh: Add --version
- dracut.sh: Add --hostonly-nics option
- EFI Mode: only write kernel cmdline to UEFI binary
- Allow $DRACUT_INSTALL to be not an absolute path
- Don't print when a module is explicitly omitted (by default)
- Remove uses of bash (and bash specific syntax) in runtime scripts
- dracut-init.sh: Add a helper for detect device kernel modules
- dracut-functions.sh: Fix check_block_and_slaves_all
- dracut-functions.sh: add a helper to check if kernel module is available

Documentation
- dracut.cmdline.7.asc: clarify usage of `rd.lvm.vg` and `rd.lvm.lv`
- dracut.conf.5.asc: document how to config --no-compress in the config
- fix CI badges in README.md and fix dracut description
- dracut.modules.7.asc: fix typos
- dracut.modules.7.asc: fix reference to insmodpost module
- Add --version to man page
- Adding code of conduct
- Document initqueue/online hook


dracut-install:
- install: also install post weak dependencies of kernel modules
- install: Globbing support for resolving "firmware:"

mkinitrd:
- use vmlinux regex for ppc*, vmlinuz for i686

mkinitrd-suse:
- fix i586 platform detection

modules:

00systemd:
- skip dependency add for non-existent units
- add missing cryptsetup-related targets

05busybox:
- simplify listing of supported utilities

06rngd:
- install dependant libs too
- Do not start inside container

10i18n:
- i18n: Always install /etc/vconsole.conf

35network-legacy:
- dhclient-script: Fix typo in output of  BOUND & BOUND6 cases
- simplify fallback dhcp setup

35network-manager:
- ensure that nm-run.sh is executed when needed
- install libnss DNS and mDNS plugins
- always pull in machinery to read ifcfg files
- set kernel hostname from the command line
- move connection generation to a lib file

40network:
- fix glob matching ipv6 addresses
- net-lib.sh: support infiniband network mac addresses

45url-lib:
- drop NSS if it's not in curl --version

80cms:
- regenerate NetworkManager connections

90btrfs:
- force preload btrfs module
- Install crypto modules in 90kernel-modules

90crypt:
- cryptroot-ask: no warn if /run/cryptsetup exist
- install crypto modules in 90kernel-modules
- try to catch kernel config changes
- fix force on multiple lines
- pull in remote-cryptsetup.target enablement
- cryptroot-ask: unify /etc/crypttab and rd.luks.key

90dmsquash-live:
- iso-scan.sh: Provide an easy reference to iso-scan device

90kernel-modules:
- remove nfit from static module list (see nvdimm module)
- install crypto modules in 90kernel-modules
- add sg kernel module
- add pci_hyperv
- install block drivers more strictly
- install less modules for hostonly mode
- arm: add drivers/hwmon for arm/arm64

90kernel-network-modules
- on't install iscsi related module (use 95iscsi)

90lvm:
- remove unnecessary ${initdir} from lvm_scan.sh
- fix removal of pvscan from udev rules
- do not add newline to cmdline

90multipath:
- add automatic configuration for multipath
  (adds 'rd.multipath=default' to use the default config)
- install kpartx's 11-dm-parts.rules

90nvdimm:
- new module for NVDIMM support

90ppcmac:
- respect DRACUT_ARCH, don't exclude ppcle

90qemu-net:
- in hostonly mode, only install if network is needed
- install less module for strict hostonly mode

91zipl:
- parse-zipl.sh: honor SYSTEMD_READY

95cifs:
- pass rootflags to mount
- install new softdeps (sha512, gcm, ccm, aead2)

95dasd:
- only install /etc/dasd.conf if present

95dcssblk:
- fix script permissions

95fcoe:
- fix pre-trigger stage by replacing exit with return in lldpad.sh
- default rd.nofcoe to false
- don't install if there is no FCoE hostonly devices

95iscsi:
- fix missing space when compiling cmdline args
- fix ipv6 target discovery

95nfs:
- only install rpc services for NFS < 4 when hostonly is strict
- Change the order of NFS servers during the boot
  (next-server option has higher priority than DHCP-server itself)
- install less module if hostonly mode is strict

95nvmf:
- add module for NVMe-oF
- add NVMe over TCP support

95resume:
- do not resume on iSCSI, FCoE or NBD

95rootfs-block:
- mount-root.sh: fix writing fstab file with missing fsck flag
- only write root argument for block device

95zfcp:
- match simplified rd.zfcp format too

95zfcp_rules:
- parse-zfcp.sh: remove rule existence check

95znet:
- add a rd.znet_ifname= option

98dracut-systemd:
- remove memtrace-ko and rd.memdebug=4 support in dracut
- remove cleanup_trace_mem calls
- dracut-initqueue: Print more useful info in case of timeout
- as of v246 of systemd "syslog" and "syslog-console" switches have been deprecated
- don't wait for root device if remote cryptsetup active

99base:
- dracut-lib.sh: quote variables in parameter expansion patterns
- remove memtrace-ko and rd.memdebug=4 support in dracut
- remove cleanup_trace_mem calls
- see new module 99memstrack
- prevent creating unexpected files on the host when running dracut

99memstrack:
- memstrack is a new tool to track the overall memory usage and
  allocation, which can help off load the improve the builtin module
  memory tracing function in dracut.

99squash:
- don't hardcode the squash sub directories
- improve pre-requirements check
- check require module earlier, and properly

new modules:
- nvmf
- watchdog-modules
- dbus
- network-wicked

removed modules:
- stratis

test suite:
- use dd from /dev/zero, instead of creating files with a hole
- TEST-03-USR-MOUNT/test.sh: increase loglevel
- TEST-12-RAID-DEG/create-root.sh: more udevadm settle
- TEST-35-ISCSI-MULTI: bump disk space
- TEST-41-NBD-NM/Makefile: should be based on TEST-40-NBD not TEST-20-NFS
- TEST-99: exclude /etc/dnf/* from check

dracut-050
==========

dracut:
- support for running on a cross-compiled rootfs, see README.cross
- add support for creating secureboot signed UEFI images
- use microcode found in packed cpio images
- `-k/--kmodir` must now contain "lib/modules/$KERNEL_VERSION"
  use DRACUT_KMODDIR_OVERRIDE=1 to ignore this check
- support the EFI Stub loader's splash image feature.
  `--uefi-splash-image <FILE>`

dracut modules:
- remove bashism in various boot scripts
- emergency mode: use sulogin

fcoe:
- add rd.nofcoe option to disable the FCoE module from the command line

10i18n:
- fix keymaps not getting included sometimes
- use eurlatgr as default console font

iscsi:
- add option `rd.iscsi.testroute`

multipath:
- fix udev rules detection of multipath devices

network:
- support NetworkManager

network-legacy:
- fix classless static route parsing
- ifup: fix typo when calling dhclient --timeout
- ifup: nuke pid and lease files if dhclient failed
- fix ip=dhcp,dhcp6
- use $name instead of $env{INTERFACE} (systemd-udevd regression)

shutdown:
- fix for non-systemd reboot/halt/shutdown commands
- set selinux labels
- fix shutdown with console=null

lsinitrd:
- list squash content as well
- handle UEFI created with dracut --uefi
- make lsinitrd usable for images made with Debian mkinitramfs

dracut-install:
- fixed ldd parsing
- install kernel module dependencies of dependencies
- fixed segfault for hashing NULL pointers
- add support for compressed firmware files
- dracut_mkdir(): create parent directories as needed.

configure:
- Find FTS library with --as-needed

test suite:
- lots of cleanups
- add github actions

new modules:
- rngd
- network-manager
- ppcmac - thermal/fan control modules on PowerPC based Macs

dracut-049
==========
lsinitrd:
- record loaded kernel modules when hostonly mode is enabled
  lsinitrd $image -f */lib/dracut/loaded-kernel-modules.txt
- allow to only unpack certain files

kernel-modules:
- add gpio and pinctrl drivers for arm*/aarch64
- add nfit

kernel-network-modules:
- add vlan kernel modules

ifcfg/write-ifcfg.sh:
- aggregate resolv.conf

livenet:
- Enable OverlayFS overlay in sysroot.mount generator.

dmsquash-live:
- Support a flattened squashfs.img
- Remove obsolete osmin.img processing

dracut-systemd:
- Start systemd-vconsole-setup before dracut-cmdline-ask

iscsi:
- do not install all of /etc/iscsi unless hostonly
- start iscsid even w/o systemd

multipath:
- fixed shutdown

network:
- configure NetworkManager to use dhclient

mdraid:
- fixed uuid handling ":" versus "-"

stratis:
- Add additional binaries

new modules:
- 00warpclock
- 99squash
  Adds support for building a squashed initramfs
- 35network-legacy
  the old 40network
- 35network-manager
  alternative to 35network-legacy
- 90kernel-modules-extra
  adds out-of-tree kernel modules

testsuite:
- now runs on travis
- support new qemu device options
- even runs without kvm now

dracut-048
==========

dracut.sh:
- fixed finding of btrfs devices
- harden dracut against BASH_ENV environment variable
- no more prelinking
- scan and install "external" kernel modules
- fixed instmods with zero input
- rdsosreport: best effort to strip out passwords
- introduce tri-state hostonly mode

   Add a new option --hostonly-mode which accept an <mode> parameter, so we have a tri-state hostonly mode:

        * generic: by passing "--no-hostonly" or not passing anything.
                   "--hostonly-mode" has no effect in such case.
        * sloppy: by passing "--hostonly --hostonly-mode sloppy". This
                  is also the default mode when only "--hostonly" is given.
        * strict: by passing "--hostonly --hostonly-mode strict".

    Sloppy mode is the original hostonly mode, the new introduced strict
    mode will allow modules to ignore more drivers or do some extra job to
    save memory and disk space, while making the image less portable.

    Also introduced a helper function "optional_hostonly" to make it
    easier for modules to leverage new hostonly mode.

    To force install modules only in sloppy hostonly mode, use the form:

    hostonly="$(optional_hostonly)" instmods <modules>

dracut-install:
- don't error out, if no modules were installed
- support modules.softdep

lsinitrd.sh:
- fixed zstd file signature

kernel:
- include all pci/host modules
- add mmc/core for arm
- Include Intel Volume Management Device support

plymouth:
- fix detection of plymouth directory

drm:
- make failing installation of drm modules nonfatal
- include virtio DRM drivers in hostonly initramfs

stratis:
- initial Stratis support

crypt:
- correct s390 arch to include arch-specific crypto modules
- add cmdline rd.luks.partuuid
- add timeout option rd.luks.timeout

shutdown:
- sleep a little, if a process was killed

network:
- introduce ip=either6 option

iscsi:
- replace iscsistart with iscsid

qeth_rules:
- new module to copy qeth rules

multipath-hostonly:
- merged back into multipath

mdraid:
- fixed case if rd.md.uuid is in ID_FS_UUID format

dracut-047
==========
dracut.sh:
- sync initramfs to filesystem with fsfreeze
- introduce "--no-hostonly-default-device"
- disable lsinitrd logging when quiet
- add support for Zstandard compression
- fixed relative paths in --kerneldir
- if /boot/vmlinuz-$version exists use /boot/ as default output dir
- make qemu and qemu-net a default module in non-hostonly mode
- fixed relative symlinks
- support microcode updates for all AMD CPU families
- install all modules-load.d regardless of hostonly
- fixed parsing of "-i" and "--include"
- bump kmod version to >= 23
- enable 'early_microcode' by default
- fixed check_block_and_slaves() for nvme

lsinitrd.sh:
- dismiss "cat" error messages

systemd-bootchart:
- removed

i18n:
- install all keymaps for a given locale
- add correct fontmaps

dmsquash-live:
- fixed systemd unit escape

systemd:
- enable core dumps with systemd from initrd
- fixed setting of timeouts for device units
- emergency.service: use Type=idle and fixed task limit

multipath:
- include files from /etc/multipath/conf.d
- do not fail startup on missing configuration
- start daemon after udev settle
- add shutdown script
- parse kernel commandline option 'multipath=off'
- start before local-fs-pre.target

dracut-emergency:
- optionally print filesystem help

network:
- fixed MTU for bond master
- fixed race condition when wait for networks

fcoe:
- handle CNAs with DCB firmware support
- allow to specify the FCoE mode via the fcoe= parameter
- always set AUTO_VLAN for fcoemon
- add shutdown script
- fixup fcoe-genrules.sh for VN2VN mode
- switch back to using fipvlan for bnx2fc
- add timeout mechanism

crypt:
- add basic LUKS detached header support
- escape backslashes for systemd unit names correctly
- put block_uuid.map into initramfs

dmraid:
- do not delete partitions

dasd_mod:
- do not set module parameters if dasd_cio_free is not present

nfs:
- fix mount if IPv4 address is used in /etc/fstab
- support host being a DNS ALIAS

fips:
- fixed creating path to .hmac of kernel based on BOOT_IMAGE
- turn info calls into fips_info calls
- modprobe failures during manual module loading is not fatal


lunmask:
- add module to handle LUN masking

s390:
- add rd.cio_accept

dcssblk:
- add new module for DCSS block devices

zipl:
- add new module to update s390x configuration

iscsi:
- no more iscsid, either iscsistart or iscsid

integrity:
- support loading x509 into the trusted/builtin .evm keyring
- support X.509-only EVM configuration

plymouth:
- improve distro compatibility

dracut-046
==========

dracut.sh:
- bail out if module directory does not exist
  if people want to build the initramfs without kernel modules,
  then --no-kernel should be specified
- add early microcode support for AMD family 16h
- collect also all modaliases modules from sysfs for hostonly modules
- sync initramfs after creation

network:
- wait for IPv6 RA if using none/static IPv6 assignment
- ipv6 improvements
- Handle curl using libnssckbi for TLS
- fix dhcp classless_static_routes
- dhclient: send client-identifier matching hardware address
- don't arping for point-to-point connections
- only bring up wired network interfaces (no wlan and wwan)

mraid:
- mdraid: wait for rd.md.uuid specified devices to be assembled

crypt:
- handle rd.luks.name

crypt-gpg:
- For GnuPG >= 2.1 support OpenPGP smartcards

kernel-install:
- Skip to create initrd if /etc/machine-id is missing or empty

nfs:
- handle rpcbind /run/rpcbind directory

s390:
- various fixes

dmsquash-live:
- add NTFS support

multipath:
- split out multipath-hostonly module

lvmmerge:
- new module, see README.md in the module directory

dracut-systemd:
- fixed dependencies


dracut-045
==========

Important: dracut now requires libkmod for the dracut-install binary helper,
           which nows handles kernel module installing and filtering.

dracut.sh:
- restorecon final image file
- fail hard, if we find modules and modules.dep is missing
- support --tmpdir as a relative path
- add default path for --uefi

dracut-functions.sh:
- fix check_vol_slaves() volume group name stripping

dracut-install:
- catch ldd message "cannot execute binary file"
- added kernel module handling with libkmod
  Added parameters:
    --module,-m
    --mod-filter-path, -p
    --mod-filter-nopath, -P
    --mod-filter-symbol, -s
    --mod-filter-nosymbol, -S
    --mod-filter-noname, -N
    --silent
    --kerneldir
    --firmwaredirs
- fallback to non-hostonly mode if lsmod fails

lsinitrd:
- new option "--unpack"
- new option "--unpackearly"
- and "--verbose"

general initramfs fixes:
- don't remove 99-cmdline-ask on 'hostonly' cleanup
- call dracut-cmdline-ask.service, if /etc/cmdline.d/*.conf exists
- break at switch_root only for bare rd.break
- add rd.emergency=[reboot|poweroff|halt]
  specifies what action to execute in case of a critical failure
- rd.memdebug=4 gives information, about kernel module memory consumption
  during loading

dmsquash-live:
- fixed livenet-generator execution flag
  and include only, if systemd is used
- fixed dmsquash-live-root.sh for cases where the fstype of the liveimage is squashfs
- fixed typo for rootfs.img
- enable the use of the OverlayFS for the LiveOS root filesystem
  Patch notes:
    Integrate the option to use an OverlayFS as the root filesystem
    into the 90dmsquash-live module for testing purposes.

    The rd.live.overlay.overlayfs option allows one to request an
    OverlayFS overlay.  If a persistent overlay is detected at the
    standard LiveOS path, the overlay & type detected will be used.

    Tested primarily with transient, in-RAM overlay boots on vfat-
    formatted Live USB devices, with persistent overlay directories
    on ext4-formatted Live USB devices, and with embedded, persistent
    overlay directories on vfat-formatted devices. (Persistent overlay
    directories on a vfat-formatted device must be in an embedded
    filesystem that supports the creation of trusted.* extended
    attributes, and must provide valid d_type in readdir responses.)

    The rd.live.overlay.readonly option, which allows a persistent
    overlayfs to be mounted read only through a higher level transient
    overlay directory, has been implemented through the multiple lower
    layers feature of OverlayFS.

    The default transient DM overlay size has been adjusted up to 32 GiB.
    This change supports comparison of transient Device-mapper vs.
    transient OverlayFS overlay performance.  A transient DM overlay
    is a sparse file in memory, so this setting does not consume more
    RAM for legacy applications.  It does permit a user to use all of
    the available root filesystem storage, and fails gently when it is
    consumed, as the available free root filesystem storage on a typical
    LiveOS build is only a few GiB.  Thus, when booted on other-
    than-small RAM systems, the transient DM overlay should not overflow.

    OverlayFS offers the potential to use all of the available free RAM
    or all of the available free disc storage (on non-vfat-devices)
    in its overlay, even beyond the root filesystem available space,
    because the OverlayFS root filesystem is a union of directories on
    two different partitions.

    This patch also cleans up some message spew at shutdown, shortens
    the execution path in a couple of places, and uses persistent
    DM targets where required.

dmraid:
- added "nowatch" option in udev rule, otherwise udev would reread partitions for raid members
- allow booting from degraded MD RAID arrays

shutdown:
- handle readonly /run on shutdown

kernel-modules:
- add all HID drivers, regardless of hostonly mode
  people swap keyboards sometimes and should be able to enter their disk password
- add usb-storage
  To save the rdsosreport.txt to a USB stick, the usb-storage module is needed.
- add xennet
- add nvme

systemd:
- add /etc/machine-info
- fixed systemd-escape call for names beginning with "-"
- install missing drop-in configuration files for
    /etc/systemd/{journal.conf,system.conf}

filesystems:
- add support to F2FS filesystem (fsck and modules)

network:
- fix carrier detection
- correctly set mac address for ip=...:<mtu>:<mac>
- fixed vlan, bonding, bridging, team logic
  call ifup for the slaves and assemble afterwards
- add mtu to list of variables to store in override
- for rd.neednet=0 a bootdev is not needed anymore
- dhclient-script.sh: add classless-static-routes support
- support for iBFT IPv6
- support macaddr in brackets [] (commit 740c46c0224a187d6b5a42b4aa56e173238884cc)
- use arping2, if available
- support multiple default gateways from DHCP server
- fixup VLAN handling
- enhance team support
- differ between ipv6 local and global tentative
- ipv6: wait for a router advertised route
- add 'mtu' parameter for bond options
- use 'ip' instead of 'brctl'

nbd:
- add systemd generator
- use export names instead of port numbers, because port number based
  exports are deprecated and were removed.

fcoe:
- no more /dev/shm state copying

multipath:
- check all /dev/mapper devices if they are multipath devices, not only mpath*

fips:
- fixed .hmac installation in FIPS mode

plymouth:
- also trigger the acpi subsystem

syslog:
- add imjournal.so to read systemd journal
- move start from udev to initqueue/online

caps:
- make it a non default module

livenet:
- support nfs:// urls in livenet-generator

nfs:
- install all nfs modules non-hostonly

crypt:
- support keyfiles embedded in the initramfs

testsuite:
- add TEST-70-BONDBRIDGETEAMVLAN
- make "-cpu host" the default

dracut-044
==========
creation:
- better udev & systemd dir detection
- split dracut-functions.sh in dracut-init.sh and dracut-functions.sh
  dracut-functions.sh can now be sourced by external tools
- detect all btrfs devices needed
- added flag file if initqueue is needed
- don't overwrite anything, if initramfs image file creation failed
- if no compressor is specified, try to find a suitable one
- drop scanning kernel config for CONFIG_MICROCODE_*_EARLY
- remove "_EARLY" from CONFIG_MICROCODE_* checks
- dracut.sh: add command line option for install_i18_all
  --no-hostonly-i18n -> install_i18n_all=yes
  --hostonly-i18n -> install_i18n_all=no
- --no-reproducible to turn off reproducible mode
- dracut-function.sh can now be sourced from outside of dracut
- dracut-init.sh contains all functions, which only can be used from
  within the dracut infrastructure
- support --mount with just mountpoint as a parameter
- removed action_on_fail support
- removed host_modalias concept
- do not create microcode, if no firmware is available
- skip gpg files in microcode generation

initramfs:
- ensure pre-mount (and resume) run before root fsck
- add --online option to initqueue

qemu:
- fixed virtual machine detection

lvm:
- remove all quirk arguments for lvm >= 2.2.221

dmsquash:
- fixup for checkisomd5
- increase timeout for checkisomd5
- use non-persistent metadata snapshots for transient overlays.
- overflow support for persistent snapshot.
- use non-persistent metadata snapshots.
- avoid an overlay for persistent, uncompressed, read-write live installations.

multipath:
- multipath.conf included in hostonly mode
- install all multipath path selector kernel modules

iSCSI:
- use the iBFT initiator name, if found and set
- iscsid now present in the initramfs
- iscsistart is done with systemd-run asynchrone to do things in
  paralllel. Also restarted for every new interface which shows up.
- If rd.iscsi.waitnet (default) is set, iscsistart is done only
  after all interfaces are up.
- If not all interfaces are up and rd.iscsi.testroute (default) is set,
  the route to a iscsi target IP is checked and skipped, if there is none.
- If all things fail, we issue a "dummy" interface iscsiroot to retry
  everything in the initqueue/timeout.

network:
- added DHCP RENEW/REBIND
- IPv4 DHCP lease time now optional (bootp)
- IPv6 nfs parsing
- fixed IPv6 route parsing
- rd.peerdns=0 parameter to disable DHCP nameserver setting
- detect duplicate IPv4 addresses for static addresses
- if interfaces are specified with its enx* name, bind the correspondent MAC to the interface name
- if multiple "ip=" are present on the kernel command line "rd.neednet=1" is assumed
- add options to tweak timeouts
     rd.net.dhcp.retry=<cnt>
         If this option is set, dracut will try to connect via dhcp
         <cnt> times before failing. Default is 1.

     rd.net.timeout.dhcp=<arg>
         If this option is set, dhclient is called with "-timeout <arg>".

     rd.net.timeout.iflink=<seconds>
         Wait <seconds> until link shows up. Default is 60 seconds.

     rd.net.timeout.ifup=<seconds>
         Wait <seconds> until link has state "UP". Default is 20 seconds.

     rd.net.timeout.route=<seconds>
         Wait <seconds> until route shows up. Default is 20 seconds.

     rd.net.timeout.ipv6dad=<seconds>
         Wait <seconds> until IPv6 DAD is finished. Default is 50 seconds.

     rd.net.timeout.ipv6auto=<seconds>
         Wait <seconds> until IPv6 automatic addresses are assigned.
         Default is 40 seconds.

     rd.net.timeout.carrier=<seconds>
         Wait <seconds> until carrier is recognized. Default is 5 seconds.

IMA:
- load signed certificates in the IMA keyring, see modules.d/98integrity/README
- load EVM public key in the kernel _evm keyring

FCoE:
    fcoe: start with fcoemon instead of fipvlan

dracut-043
==========
- add missing dmsquash-generator

dracut-042
==========
- fixed dmsetup shutdown
- new kernel command line option "rd.live.overlay.thin"
    This option changes the underlying mechanism for the overlay in the
    dmsquash module.
    Instead of a plain dm snapshot a dm thin snapshot is used. The advantage
    of the thin snapshot is, that the TRIM command is recognized, which
    means that at runtime, only the occupied blocks will be claimed from
    memory, and freed blocks will really be freed in ram.
- dmsquash: Add squashfs support to rd.live.fsimg
    Previously rd.live.fsimg only supported filesystems residing in
    (compressed) archives.
    Now rd.live.fsimg can also be used when a squashfs image is used.
    This is achieved by extracting the rootfs image from the squashfs and
    then continue with the default routines for rd.live.fsimg.
- lvm: add support for LVM system id
- split up the systemd dracut module
    Basic systemd functionality is in 00systemd now.
    Switching root and the initrd.target is in 00systemd-initrd.
    Dracut additions to the systemd initrd are in 98dracut-systemd.
- support for creating a UEFI boot executable via argument "--uefi"
    With an EFI stub, the kernel, the initramfs and a kernel cmdline can be
    glued together to a single UEFI executable, which can be booted by a
    UEFI BIOS.
- network: split out kernel-network-modules, now in 90kernel-network-modules
- support for ethernet point-to-point connections configured via DHCP
- kernel-modules: install all HID drivers
- dracut.pc pkg-config file
- mount /dev, /dev/shm and /run noexec

dracut-041
==========
- fixed the shutdown loop
- fixed gzip compression for versions, which do not have --rsyncable
- fixed ifcfg generation for persistent interface names
- multipath:
  * new option to turn off multipath "rd.multipath=0" completly
  * preload scsi dh modules
  * start multipathd via systemd service
- do not fail, if user pressed ESC during media check
- fixed systemd-journal by symlinking /var/log to /run/initramfs/log
- initrd-release moved to /usr/lib
- lots of iSCSI fixes
- new "rd.timeout" to specify the systemd JobTimeoutSec for devices
- if $initrd/etc/cmdline.d/* has a "root=" and the kernel cmdline does not,
  generate a mount unit for it
- increased the initqueue timeout for non systemd initramfs to 180s
- $initrd/etc/cmdline.d/ hostonly files are now generated for NFS
- make use of systemd-hibernate-resume, if available
- fixed ldconfig parsing for hwcap output
- network: add support for comma separated autoconf options like ip=eth0:auto6,dhcp
- new parameter "rd.live.overlay.size" to specify the overlay for live images
- changed the test suite for the new sfdisk syntax
- added cache tools for dm-cache setups

dracut-040
==========
- fixed dracut module dependency checks
- fixed test suite

dracut-039
==========
- DRACUT_PATH can now be used to specify the PATH used by dracut
  to search for binaries instead of the default
  /usr/sbin:/sbin:/usr/bin:/bin
  This should be set in the distribution config file
  /usr/lib/dracut/dracut.conf.d/01-dist.conf
- add "--loginstall <DIR>" and loginstall="<DIR>" options
  to record all files, which are installed from the host fs
- "rd.writable.fsimg" - support for read/write filesystem images
- "rd.route" kernel command line parameter added
- "--install-optional" and install_optional_items added
- find plymouth pkglibdir on debian
- torrent support for live images
  root=live:torrent://example.com/liveboot.img.torrent
  and generally added as a download handler
- disable microcode, if the kernel does not support it
- speed up ldconfig_paths()
- more ARM modules
- fixed inst*() functions and "-H" handling
- fixed bridge setup
- added --force-drivers parameter and force_drivers=+ config option
  to enforce driver loading at early boot time
- documented "iso-scan/filename" usage in grub
- various bugfixes

dracut-038
==========
- "rd.cmdline=ask" will ask the user on the console to enter additional
  kernel command line parameters
- "rd.hostonly=0" removes all "hostonly" added custom files,
  which is useful in combination with "rd.auto" or other specific parameters,
  if you want to boot on the same hardware, but the compiled in configuration
  does not match your setup anymore
- inst* functions and dracut-install now accept the "-H" flag, which logs all
  installed files to /lib/dracut/hostonly-files. This is used to remove those
  files, if rd.hostonly is given on the kernel command line
- strstr now only does literal string match,
  please use strglob and strglobin for globs
- fixed unpacking of the microcode image on shutdown
- added systemd-gpt-auto-generator
- fcoe: wait for lldpad to be ready
- network: handle "ip=dhcp6"
- network: DCHPv6: set valid_lft and preferred_lft
- dm: support dm-cache
- fstab: do not mount and fsck from fstab if using systemd
- break at switch_root only for bare rd.break and not for any rd.break=...
- nbd: make use of "--systemd-mark", otherwise it gets killed on switch_root
- fcoe-uefi: fixed cmdline parameter generation
- iscsi: deprecate "ip=ibft", use "rd.iscsi.ibft[=1]" from now on
- "lsinitrd -m" now only lists the dracut modules of the image
- a lot of small bugfixes

dracut-037
==========
- dracut: hostonly_cmdline variable and command line switch
    Toggle hostonly cmdline storing in the initramfs
    --hostonly-cmdline:
        Store kernel command line arguments needed in the initramfs
    --no-hostonly-cmdline:
        Do not store kernel command line arguments needed in the initramfs
- dracut: --mount now understands full fstab lines
- dracut now also includes drivers from the /lib/modules/<version>/updates directory
- dracut: only set the owner of files to 0:0, if generated as non-root
- dracut now directly writes to the initramfs file
- dracut: call lz4 with the legacy flag (linux kernel does not support the new format)
- systemd: rootfs-generator generates JobTimeout=0 units for the root device
- systemd: added the systemd-sysctl service
- systemd: add 80-net-setup-link.rules and .link files for persistent interface renaming
- systemd: make dracut-shutdown.service failure non-fatal
- network: various IPv6 fixes
- network: DCHCP for IPv6
- network: understand ip=.....:<dns1>:<dns2>
- network: parse ibft nameserver settings
- shutdown: if kexec fails, just reboot
- lvm: handle one LV at a time with lvchange
- module-setup.sh:
    New functions require_binaries() and require_any_binary() to be used
    in the check() section of module-setup.sh.
- a lot of small bugfixes

Contributions from:
Harald Hoyer
Alexander Tsoy
Till Maas
Amadeusz Żołnowski
Brian C. Lane
Colin Guthrie
Dave Young
WANG Chao
Shawn W Dunn

dracut-036
==========
- fixed skipcpio signature checking

dracut-035
==========
- changed dracut tarball compression to xz
- new argument "--rebuild"
- add lzo, lz4 compression
- install: install all binaries with <name> found in PATH
- lsinitrd can now handle initramfs images with an early cpio prepended
  (microcode, ACPI tables)
- mkinitrd-suse added as a compat stub for dracut
- lvm: install thin utils for non-hostonly
- resume: fix swap detection in hostonly
- avoid loading unnecessary 32-bit libraries for 64-bit initrds
- crypt: wait for systemd password agents
- crypt: skip crypt swaps with password files
- network: before doing dhcp, dracut now checks, if the link has a carrier
- network: dhclient-script.sh now sets the lease time
- network: include usbnet drivers
- network: include all ethernet drivers
- network: add rd.bootif=0 to ignore BOOTIF
- i18n: introduce i18n_install_all, to install everything i18n related
- support SuSE DASD configurations
- support SuSE zfcp configurations
- support SuSE compressed KEYMAP= setting
- usrmount: always install the module,
  so always mount /usr from within the initramfs
- test/TEST-17-LVM-THIN: new test case for lvm thin pools
- "halt" the machine in systemd mode for die()

dracut-034
==========
- do not run dhcp on parts of assembled network interfaces (bond, bridge)
- add option to turn on/off prelinking
    --prelink, --noprelink
    do_prelink=[yes|no]
- add ACPI table overriding
- do not log to syslog/kmsg/journal for UID != 0
- lvm/mdraid: Fix LVM on MD activation
- bcache module removed (now in bcache-tools upstream)
- mdadm: also install configs from /etc/mdadm.conf.d
- fixes for mdadm-3.2.6+
- mkinitrd: better compat support for SUSE
- fcoe: add FCoE UEFI boot device support
- rootfs-block: add support for the rootfallback= kernel cmdline option

Contributions from:
Thomas Renninger
Alexander Tsoy
Peter Rajnoha
WANG Chao
Harald Hoyer


dracut-033
==========
- improved hostonly device recognition
- improved hostonly module recognition
- add dracut.css for dracut.html
- do not install udev rules from /etc in generic mode
- fixed LABEL= parsing for swap devices
- fixed iBFT network setup
- url-lib.sh: handle 0-size files with curl
- dracut.asc: document debugging dracut on shutdown
- if rd.md=0, use dmraid for imsm and ddf
- skip empty dracut modules
- removed caching of kernel cmdline
- fixed iso-scan, if the loop device driver is a kernel module
- bcache: support new blkid
- fixed ifup udev rules
- ifup with dhcp, if no "ip=" specified for the interface

Contributions from:
WANG Chao
Colin Walters
Harald Hoyer


dracut-032
==========
- add parameter --print-cmdline
    This prints the kernel command line parameters for the current disk
    layout.
    $ dracut --print-cmdline
    rd.luks.uuid=luks-e68c8906-6542-4a26-83c4-91b4dd9f0471
    rd.lvm.lv=debian/root rd.lvm.lv=debian/usr root=/dev/mapper/debian-root
    rootflags=rw,relatime,errors=remount-ro,user_xattr,barrier=1,data=ordered
    rootfstype=ext4
- dracut.sh: add --persistent-policy option and persistent_policy conf option
    --persistent-policy <policy>:
        Use <policy> to address disks and partitions.
        <policy> can be any directory name found in /dev/disk.
        E.g. "by-uuid", "by-label"
- dracut now creates the initramfs without udevadm
  that means the udev database does not have to populated
  and the initramfs can be built in a chroot with
  /sys /dev /proc mounted
- renamed dracut_install() to inst_multiple() for consistent naming
- if $libdirs is unset, fall back to ld.so.cache paths
- always assemble /usr device in initramfs
- bash module added (disable it, if you really want dash)
- continue to boot, if the main loop times out, in systemd mode
- removed inst*() shell pure versions, dracut-install binary is in charge now
- fixed ifcfg file generation for vlan
- do not include adjtime and localtime anymore
- fixed generation of zfcp.conf of CMS setups
- install vt102 terminfo
  dracut_install() is still there for backwards compat
- do not strip files in FIPS mode
- fixed iBFT interface configuration
- fs-lib: install fsck and fsck.ext*
- shutdown: fixed killall_proc_mountpoint()
- network: also wait for ethernet interfaces to setup
- fixed checking for FIPS mode

Contributions from:
Harald Hoyer
WANG Chao
Baoquan He
Daniel Schaal
Dave Young
James Lee
Radek Vykydal


dracut-031
==========
- do not include the resume dracut module in hostonly mode,
  if no swap is present
- don't warn twice about omitted modules
- use systemd-cat for logging on systemd systems, if logfile is unset
- fixed PARTUUID parsing
- support kernel module signing keys
- do not install the usrmount dracut module in hostonly mode,
  if /sbin/init does not live in /usr
- add debian udev rule files
- add support for bcache
- network: handle bootif style interfaces
  e.g. ip=77-77-6f-6f-64-73:dhcp
- add support for kmod static devnodes
- add vlan support for iBFT

Contributions from:
Harald Hoyer
Amadeusz Żołnowski
Brandon Philips
Colin Walters
James Lee
Kyle McMartin
Peter Jones

dracut-030
==========
- support new persistent network interface names
- fix findmnt calls, prevents hang on stale NFS mounts
- add systemd.slice and slice.target units
- major shell cleanup
- support root=PARTLABEL= and root=PARTUUID=
- terminfo: only install l/linux v/vt100 and v/vt220
- unset all LC_* and LANG, 10% faster
- fixed dependency loop for dracut-cmdline.service
- do not wait_for_dev for the root devices
- do not wait_for_dev for devices, if dracut-initqueue is not needed
- support early microcode loading with --early-microcode
- dmraid, let dmraid setup its own partitions
- sosreport renamed to rdsosreport

Contributions from:
Harald Hoyer
Konrad Rzeszutek Wilk
WANG Chao

dracut-029
==========
- wait for IPv6 autoconfiguration
- i18n: make the default font configurable
  To set the default font for your distribution, add
  i18n_default_font="latarcyrheb-sun16"
  to your /lib/dracut/dracut.conf.d/01-dist.conf distribution config.
- proper handle "rd.break" in systemd mode before switch-root
- systemd: make unit files symlinks
- build without dash requirement
- add dracut-shutdown.service.8 manpage
- handle MACs for "ip="
  "ip=77-77-6f-6f-64-73:dhcp"
- don't explode when mixing BOOTIF and ip=
- 90lvm/module-setup.sh: redirect error message of lvs to /dev/null

Contributions from:
Harald Hoyer
Will Woods
Baoquan He

dracut-028
==========
- full integration of crypto devs in systemd logic
- support for bridge over team and vlan tagged team
- support multiple bonding interfaces
- new kernel command line param "rd.action_on_fail"
  to control the emergency action
- support for bridge over a vlan tagged interface
- support for "iso-scan/filename" kernel parameter
- lsinitrd got some love and does not use "file" anymore
- fixed issue with noexec mounted tmp dirs
- FIPS mode fixed
- dracut_install got some love
- fixed some /usr mounting problems
- ifcfg dracut module got some love and fixes
- default installed font is now latarcyrheb-sun16
- new parameters rd.live.dir and rd.live.squashimg
- lvm: add tools for thin provisioning
- also install non-hwcap libs
- setup correct system time and time zone in initrd
- s390: fixed cms setup
- add systemd-udevd persistent network interface naming

Contributions from:
Harald Hoyer
Kamil Rytarowski
WANG Chao
Baoquan He
Adam Williamson
Colin Guthrie
Dan Horák
Dave Young
Dennis Gilmore
Dennis Schridde

dracut-027
==========
- dracut now has bash-completion
- require bash version 4
- systemd module now requires systemd >= 199
- dracut makes use of native systemd initrd units
- added hooks for new-kernel-pkg and kernel-install
- hostonly is now default for fedora
- comply with the BootLoaderSpec paths
  http://www.freedesktop.org/wiki/Specifications/BootLoaderSpec
- added rescue module
- host_fs_types is now a hashmap
- new dracut argument "--regenerate-all"
- new dracut argument "--noimageifnotneeded"
- new man page dracut.bootup
- install all host filesystem drivers
- use -D_FILE_OFFSET_BITS=64 to build dracut-install

dracut-026
==========
- introduce /usr/lib/dracut/dracut.conf.d/ drop-in directory

  /usr/lib/dracut/dracut.conf.d/*.conf can be overwritten by the same
  filenames in /etc/dracut.conf.d.

  Packages should use /usr/lib/dracut/dracut.conf.d rather than
  /etc/dracut.conf.d for drop-in configuration files.

  /etc/dracut.conf and /etc/dracut.conf.d belong to the system administrator.

- uses systemd-198 native initrd units
- totally rely on the fstab-generator in systemd mode for block devices
- dracut systemd now uses dracut.target rather than basic.target
- dracut systemd services optimize themselves away
- fixed hostonly parameter generation
- turn off curl globbing (fixes IPv6)
- modify the udev rules on install and not runtime time
- enable initramfs building without kernel modules (fixed regression)
- in the initqueue/timeout,
  reset the main loop counter, as we see new udev events or initqueue/work
- fixed udev rule installation

dracut-025
==========
- do not strip signed kernel modules
- add sosreport script and generate /run/initramfs/sosreport.txt
- make short uuid specification for allow-discards work
- turn off RateLimit for the systemd journal
- fixed MAC address assignment
- add systemd checkisomd5 service
- splitout drm kernel modules from plymouth module
- add 'swapoff' to initramfs to fix shutdown/reboot
- add team device support
- add pre-shutdown hook
- kill all processes in shutdown and report remaining ones
- "--device" changed to "--add-device" and "add_device=" added for conf files
- add memory usage trace to different hook points
- cope with optional field #7 in /proc/self/mountinfo
- lots of small bugfixes

dracut-024
==========
- new dracut option "--device"
- new dracut kernel command line options "rd.auto"
- new dracut kernel command line options "rd.noverifyssl"
- new dracut option "--kernel-cmdline" and "kernel_cmdline" option for default parameters
- fixes for systemd and crypto
- fix for kexec in shutdown, if not included in initramfs
- create the initramfs non-world readable
- prelink/preunlink in the initramfs
- strip binaries in the initramfs by default now
- various FIPS fixes
- various dracut-install fixes

dracut-023
==========
- resume from hibernate fixes
- -N option for --no-hostonly
- support for systemd crypto handling
- new dracut module "crypt-loop"
- deprecate the old kernel command line options
- more documentation
- honor CFLAGS for dracut-install build
- multipath fixes
- / is mounted according to rootflags parameter but forced ro at first.
  Later it is remounted according to /etc/fstab + rootflags parameter
  and "ro"/"rw".
- support for xfs / reiserfs separate journal device
- new "ro_mnt" option to force ro mount of / and /usr
- root on cifs support
- dracut-install: fixed issue for /var/tmp containing a symlink
- only lazy resolve with ldd, if the /var/tmp partition is not mounted with "noexec"
- i18n: fixed inclusion of "include" keymaps

dracut-022
==========
- fixed host-only kernel module bug

dracut-021
==========
- fixed systemd in the initramfs (requires systemd >= 187)
- dracut-install: massive speedup with /var on the same filesystem with COW copy
- dracut-install: moved to /usr/lib/dracut until it becomes a general purpose tool
- new options: "rd.usrmount.ro" and "rd.skipfsck"
- less mount/umount
- apply "ro" on the kernel command line also to /usr
- mount according to fstab, if neither "ro" or "rw" is specified
- skip fsck for xfs and btrfs. remount is enough
- give emergency_shell if /usr mount failed
- dracut now uses getopt:
  * options can be position independent now!!
  * we can now use --option=<arg>
- added option "--kver=<kernel-version>", and the image location can be omitted
  # dracut --kver 3.5.0-0.rc7.git1.2.fc18.x86_64
- dracut.sh: for --include copy also the symbolic links
- man pages: lsinitrd and mkinitrd added
- network: We do not support renaming in the kernel namespace anymore (as udev does
  that not anymore). So, if a user wants to use ifname, he has to rename
  to a custom namespace. "eth[0-9]+" is not allowed anymore. !!!!!
- resume: moved the resume process to the initqueue.
  This should prevent accidently mounting the root file system.
- testsuite: add support for: make V=1 TESTS="01 20 40" check
    $ sudo make V=1 clean check
    now runs the testsuite in verbose mode

    $ sudo make TESTS="01 20 40" clean check
    now only runs the 01, 20 and 40 tests.

dracut-020
==========
- changed rd.dasd kernel parameter
- arm kernel modules added to kernel-modules
- make udevdir systemdutildir systemdsystemunitdir global vars
  your distribution should ship those settings in
  /etc/dracut.conf.d/01-distro.conf
  see dracut.conf.d/fedora.conf.example
- kernel modules are now only handled with /sys/modules and modules.dep
- systemd fixups
- mdraid: wait for md devices to be clean, before shutdown
- ifup fixed for ipv6
- add PARTUUID as root=PARTUUID=<partition uuid> parameter
- fixed instmods() return code and set pipefail globally
- add 04watchdog dracut module
- dracut-shutdown.service: fixed ordering to be before shutdown.target
- make use of "ln -r" instead of shell functions, if new coreutils is installed
- network: support vlan tagged bonding
- new dracut module qemu and qemu-net to install all kernel driver
- fs-lib/fs-lib.sh: removed test mounting of btrfs and xfs
- no more "mknod" in the initramfs!!
- replaced all "tr" calls with "sed"
- speedup with lazy kernel module dependency resolving
- lots of speedup optimizations and last but not least
- dracut-install:
  - new binary to significanlty speedup the installation process
  - dracut-functions.sh makes use of it, if installed


dracut-019
==========
- initqueue/online hook
- fixes for ifcfg write out
- rootfs-block: avoid remount when options don't change
- Debian multiarch support
- virtfs root filesystem support
- cope with systemd-udevd
- mount tmpfs with strictatime
- include all kernel/drivers/net/phy drivers
- add debug_on() and debug_off() functions
- add arguments for source_hook() and source_all()
- cleanup hook
- plymouth: get consoledev from /sys/class/tty/console/active
- experimental systemd dracut module for systemd in the initramfs
- install xhci-hcd kernel module
- dracut: new "--mount" option
- lsinitrd: new option --printsize
- ARM storage kernel modules added
- s390 cms conf file support
- /etc/initrd-release in the initrd
- vlan support
- full bonding and bridge support
- removed scsi_wait_scan kernel module from standard install
- support rd.luks.allow-discards and honor options in crypttab
- lots of bugfixes

dracut-018
==========
- lvm: ignore lvm mirrors
- lsinitrd: handle LZMA images
- iscsi: add rd.iscsi.param
- iscsi: add iscsi interface binding
- new module cms to read and handle z-Series cms config files
- fixed fstab.sys handling
- new dracut option "--tmpdir"
- new dracut option "--no-hostonly"
- nbd: name based nbd connects
- converted manpage and documentation source to asciidoc
- write-ifcfg fixes and cleanups
- ifup is now done in the initqueue
- netroot cleanup
- initqueue/online is now for hooks, which require network
- no more /tmp/root.info
- 98pollcdrom: factored out the ugly cdrom polling in the main loop
- simplified rd.luks.uuid testing
- removed "egrep" and "ls" calls
- speedup kernel module installation
- make bzip2 optional
- lots of bugfixes

dracut-017
==========
- a _lot_ faster than dracut-016 in image creation
- systemd service dracut-shutdown.service
- livenet fixes
- ssh-client module install fix
- root=iscsi:... fixed
- lots of restructuring and optimizing in dracut-functions.sh
- usrmount: honor fs_passno in /etc/fstab
- renamed all shell scripts to .sh
- new option "--omit-drivers" and config option "omit_drivers"
- hostonly mode fixups

dracut-016
==========
- fixed lsinitrd
- honor binaries in sbin first
- fixed usrmount module
- added systemd service for shutdown
- fixed terminfo on distros with /usr/share/terminfo
- reload udev rules after "pre-trigger" hook
- improved test suite
- new parameter "--omit-drivers" and new conf param omit_drivers
- "--offroot" support for mdraid
- new libs: net-lib.sh, nfs-lib.sh, url-lib.sh, img-lib.sh
  full of functions to use in your dracut module

dracut-015
==========
- hostonly mode automatically adds command line options for root and /usr
- --add-fstab --mount parameters
- ssh-client module
- --ctty option: add job control
- cleanup /run/initramfs
- convertfs module
- /sbin/ifup can be called directly
- support kernel modules compressed with xz
- s390 iscsi modules added
- terminfo module
- lsinitrd can handle concatened images
- lsinitrd can sort by size

dracut-014
==========
- new dracut arguments:
  --lvmconf
  --nolvmconf
  --fscks [LIST]
  --nofscks
- new .conf options:
  install_items
  fscks
  nofscks
- new kernel options:
  rd.md.ddf
  rd.md.waitclean
  plymouth.enable
- dracut move from /sbin to /usr/bin
- dracut modules dir moved from /usr/share/dracut to /usr/lib/dracut
- profiling with "dracut --profile"
- new TEST-16-DMSQUASH, test for Fedora LiveCDs
- speedup of initramfs creation
- ask_for_password fallback to CLI
- mdraid completely switched to incremental assembly
- no more cdrom polling
- "switch_root" breakpoint is now very late
- /dev/live is gone
- /dev/root is gone
- fs-lib dracut module for fscks added
- xen dracut module removed
- usb mass storage kernel drivers now included
- usrmount dracut module added:
  mount /usr if found in /sysroot/etc/fstab
- only include fsck helper needed for hostonly
- fcoe: support for bnx2fc
- support iSCSI drivers: qla4xxx, cxgb3i, cxgb4i, bnx2i, be2iscsi
- fips-aesni dracut module added
- add install_items to dracut.conf
    install_items+=" <file>[ <file> ...] "
- speedup internal testsuite
- internal testsuite: store temporary data in a temporary dir

dracut-013
==========
- speedup of initramfs creation
- fixed inst_dir for symbolic links
- add unix kernel module

dracut-012
==========
- better fsck handling
- fixed wait condition for LVM volumes
- fix for hardlinks (welcome Debian! :-)
- shutdown bugfixes
- automatic busybox symlink creation
- try to mount /usr, if init points to a path in /usr
- btrfs with multiple devices
- "--force-add" option for dracut, to force-add dracut modules,
  without hostonly checks
- lsinitrd also display the initramfs size in human readable form
- livenet module, to mount live-isos over http
- masterkey,ecryptfs,integrity security modules
- initqueue/timeout queue e.g. for starting degraded raids
- "make rpm" creates an rpm with an increasing release number from any
  git checkout
- support lvm mirrors
- start degraded lvm mirrors after a timeout
- start degraded md raids after a timeout
- getarg() now returns wildcards without file matching to the current fs
- lots of bugfixes

dracut-011
==========
- use udev-168 features for shutting down udev
- introduce "--prefix" to put all initramfs files in e.g "/run/initramfs"
- new shutdown script (called by systemd >= 030) to disassemble the root device
- lots of bugfixes
- new module for gpg-encrypted keys - 91crypt-gpg

dracut-010
==========
- lots of bugfixes
- plymouth: use /run/plymouth/pid instead of /run/initramfs/plymouth
- add "/lib/firmware/updates" to default firmware path

dracut-009
==========
- dracut generator
  - dracut-logger
  - xz compression
  - better argument handling

- initramfs
  - hooks moved to /lib/dracut/hooks in initramfs
  - rd.driver.{blacklist|pre|post} accept comma separated driver list
  - iSCSI: iSCSI Boot Firmware Table (iBFT) support
  - support for /run
  - live image: support for generic rootfs.img (instead of ext3fs.img)
  - caps module
  - FCoE: EDD support

dracut-008
==========
- removed --ignore-kernel-modules option (no longer necessary)
- renamed kernel command line arguments to follow the rd. naming scheme
- merged check, install, installkernel to module-setup.sh
- support for bzip2 and xz compressed initramfs images.
- source code beautification
- lots of documentation
- lsinitrd: "catinitrd" functionality
- dracut: --list-modules
- lvm: support for dynamic LVM SNAPSHOT root volume
- 95fstab-sys: mount all /etc/fstab.sys volumes before switch_root
- 96insmodpost dracut module
- rd.shell=1 per default
- rootfs-block:mount-root.sh add fsck
- busybox shell replacements module
- honor old "real_init="
- 97biosdevname dracut module

dracut-007
==========
- module i18n is no longer fedora/red hat specific (Amadeusz Żołnowski)
- distribution specific conf file
- bootchartd support
- debug module now has fsck
- use "hardlink", if available, to save some space
- /etc/dracut.conf can be overwritten by settings in /etc/dracut.conf.d/*.conf
- gentoo splash module
- --ignore-kernel-modules option
- crypto keys on external devices support
- bugfixes

dracut-006
==========
- fixed mdraid with IMSM
- fixed dracut manpages
- dmraid parse different error messages
- add cdrom polling mechanism for slow cdroms
- add module btrfs
- add btrfsctl scan for btrfs multi-devices (raid)
- teach dmsquash live-root to use rootflags
- trigger udev with action=add
- fixed add_drivers handling
- add sr_mod
- use pigz instead of gzip, if available
- boot from LVM mirrors and snapshots
- iscsi: add support for multiple netroot=iscsi:
- Support old version of module-init-tools
- got rid of rdnetdebug
- fixed "ip=auto6"
- dracut.conf: use "+=" as default for config variables
- bugfixes

dracut-005
==========
- dcb support to dracut's FCoE support
- add readonly overlay support for dmsquash
- add keyboard kernel modules
- dracut.conf: added add_dracutmodules
- add /etc/dracut.conf.d
- add preliminary IPv6 support
- bugfixes

dracut-004
==========
- dracut-lib: read multiple lines from $init/etc/cmdline
- lsinitrd and mkinitrd
- dmsquash: add support for loopmounted *.iso files
- lvm: add rd_LVM_LV and "--poll n"
- user suspend support
- add additional drivers in host-only mode, too
- improved emergency shell
- support for compressed kernel modules
- support for loading Xen modules
- rdloaddriver kernel command line parameter
- man pages for dracut-catimages and dracut-gencmdline
- bugfixes

dracut-003
==========
- add debian package modules
- add dracut.conf manpage
- add module 90multipath
- add module 01fips
- crypt: ignore devices in /etc/crypttab (root is not in there)
  unless rd_NO_CRYPTTAB is specified
- kernel-modules: add scsi_dh scsi_dh_rdac scsi_dh_emc
- add multinic support
- add s390 zfcp support
- add s390 dasd support
- add s390 network support
- fixed dracut-gencmdline for root=UUID or LABEL
- do not destroy assembled raid arrays if mdadm.conf present
- mount /dev/shm
- let udevd not resolve group and user names
- moved network from udev to initqueue
- improved debug output: specifying "rdinitdebug" now logs
  to dmesg, console and /init.log
- strip kernel modules which have no x bit set
- redirect stdin, stdout, stderr all RW to /dev/console
  so the user can use "less" to view /init.log and dmesg
- add new device mapper udev rules and dmeventd
- fixed dracut-gencmdline for root=UUID or LABEL
- do not destroy assembled raid arrays if mdadm.conf present
- mount /dev/shm
- let udevd not resolve group and user names
- preserve timestamps of tools on initramfs generation
- generate symlinks for binaries correctly
- moved network from udev to initqueue
- mount nfs3 with nfsvers=3 option and retry with nfsvers=2
- fixed nbd initqueue-finished
- improved debug output: specifying "rdinitdebug" now logs
  to dmesg, console and /init.log
- strip kernel modules which have no x bit set
- redirect stdin, stdout, stderr all RW to /dev/console
  so the user can use "less" to view /init.log and dmesg
- make install of new dm/lvm udev rules optionally
- add new device mapper udev rules and dmeventd
- Fix LiveCD boot regression
- bail out if selinux policy could not be loaded and
  selinux=0 not specified on kernel command line
- do not cleanup dmraids
- copy over lvm.conf

dracut-002
==========
- add ifname= argument for persistent netdev names
- new /initqueue-finished to check if the main loop can be left
- copy mdadm.conf if --mdadmconf set or mdadmconf in dracut.conf
- plymouth: use plymouth-populate-initrd
- add add_drivers for dracut and dracut.conf
- add modprobe scsi_wait_scan to be sure everything was scanned
- fix for several problems with md raid containers
- fix for selinux policy loading
- fix for mdraid for IMSM
- fix for bug, which prevents installing 61-persistent-storage.rules (bug #520109)
- fix for missing grep for md

dracut-001
==========
- better --hostonly checks
- better lvm/mdraid/dmraid handling
- fcoe booting support
    Supported cmdline formats:
    fcoe=<networkdevice>:<dcb|nodcb>
    fcoe=<macaddress>:<dcb|nodcb>

    Note currently only nodcb is supported, the dcb option is reserved for
    future use.

    Note letters in the macaddress must be lowercase!

    Examples:
    fcoe=eth0:nodcb
    fcoe=4A:3F:4C:04:F8:D7:nodcb

- Syslog support for dracut
    This module provides syslog functionality in the initrd.
    This is especially interesting when complex configuration being
    used to provide access to the device the rootfs resides on.


dracut-0.9
==========
- let plymouth attach to the terminal (nice text output now)
- new kernel command line parameter "rdinfo" show dracut output, even when
  "quiet" is specified
- rd_LUKS_UUID is now handled correctly
- dracut-gencmdline: rd_LUKS_UUID and rd_MD_UUID is now correctly generated
- now generates initrd-generic with around 15MB
- smaller bugfixes

dracut-0.8
==========
- iSCSI with username and password
- support for live images (dmsquashed live images)
- iscsi_firmware fixes
- smaller images
- bugfixes

dracut-0.7
==========
- dracut:     strip binaries in initramfs

           --strip
                  strip binaries in the initramfs (default)

           --nostrip
                  do not strip binaries in the initramfs
- dracut-catimages

    Usage: ./dracut-catimages [OPTION]... <initramfs> <base image>
    [<image>...]
    Creates initial ramdisk image by concatenating several images from the
    command
    line and /boot/dracut/

      -f, --force           Overwrite existing initramfs file.
      -i, --imagedir        Directory with additional images to add
                            (default: /boot/dracut/)
      -o, --overlaydir      Overlay directory, which contains files that
                            will be used to create an additional image
      --nooverlay           Do not use the overlay directory
      --noimagedir          Do not use the additional image directory
      -h, --help            This message
      --debug               Output debug information of the build process
      -v, --verbose         Verbose output during the build process

- s390 dasd support

dracut-0.6
==========
- dracut: add --kernel-only and --no-kernel arguments

           --kernel-only
                  only install kernel drivers and firmware files

           --no-kernel
                  do not install kernel drivers and firmware files

    All kernel module related install commands moved from "install"
    to "installkernel".

    For "--kernel-only" all installkernel scripts of the specified
    modules are used, regardless of any checks, so that all modules
    which might be needed by any dracut generic image are in.

    The basic idea is to create two images. One image with the kernel
    modules and one without. So if the kernel changes, you only have
    to replace one image.

    Grub and the kernel can handle multiple images, so grub entry can
    look like this:

    title Fedora (2.6.29.5-191.fc11.i586)
            root (hd0,0)
            kernel /vmlinuz-2.6.29.5-191.fc11.i586 ro rhgb quiet
            initrd /initrd-20090722.img /initrd-kernel-2.6.29.5-191.fc11.i586.img /initrd-config.img

    initrd-20090722.img
      the image provided by the initrd rpm
      one old backup version is kept like with the kernel

    initrd-kernel-2.6.29.5-191.fc11.i586.img
      the image provided by the kernel rpm

    initrd-config.img
      optional image with local configuration files

- dracut: add --kmoddir directory, where to look for kernel modules

           -k, --kmoddir [DIR]
                  specify the directory, where to look for kernel modules



dracut-0.5
==========
- more generic (all plymouth modules, all keyboards, all console fonts)
- more kernel command line parameters (see also man dracut(8))
- a helper tool, which generates the kernel command line (dracut-gencmdline)
- bridged network boot
- a lot of new command line parameter

dracut-0.4
==========
- bugfixes
- firmware loading support
- new internal queue (initqueue)
    initqueue now loops until /dev/root exists or root is mounted

    init now has the following points to inject scripts:

    /cmdline/*.sh
       scripts for command line parsing

    /pre-udev/*.sh
       scripts to run before udev is started

    /pre-trigger/*.sh
       scripts to run before the main udev trigger is pulled

    /initqueue/*.sh
       runs in parallel to the udev trigger
       Udev events can add scripts here with /sbin/initqueue.
       If /sbin/initqueue is called with the "--onetime" option, the script
       will be removed after it was run.
       If /initqueue/work is created and udev >= 143 then this loop can
       process the jobs in parallel to the udevtrigger.
       If the udev queue is empty and no root device is found or no root
       filesystem was mounted, the user will be dropped to a shell after
       a timeout.
       Scripts can remove themselves from the initqueue by "rm $job".

    /pre-mount/*.sh
       scripts to run before the root filesystem is mounted
       NFS is an exception, because it has no device node to be created
       and mounts in the udev events

    /mount/*.sh
       scripts to mount the root filesystem
       NFS is an exception, because it has no device node to be created
       and mounts in the udev events
       If the udev queue is empty and no root device is found or no root
       filesystem was mounted, the user will be dropped to a shell after
       a timeout.

    /pre-pivot/*.sh
       scripts to run before the real init is executed and the initramfs
       disappears
       All processes started before should be killed here.

    The behaviour of the dmraid module demonstrates how to use the new
    mechanism. If it detects a device which is part of a raidmember from a
    udev rule, it installs a job to scan for dmraid devices, if the udev
    queue is empty. After a scan, it removes itsself from the queue.



dracut-0.3
==========

- first public version
