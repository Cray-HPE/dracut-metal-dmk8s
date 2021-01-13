# Copyright 2020 Hewlett Packard Enterprise Development LP
%define namespace dracut
# disable compressing files
%define __os_install_post %{nil}
%define intranamespace_name metal-dmk8s
%define x_y_z %(cat .version)
%define release_extra %(if [ -e "%{_sourcedir}/_release_extra" ] ; then cat "%{_sourcedir}/_release_extra"; else echo ""; fi)
%define source_name %{name}

################################################################################
# Primary package definition #
################################################################################

Name: %{namespace}-%{intranamespace_name}
Packager: <rustydb@hpe.com>
Release: %(echo ${BUILD_METADATA})
Vendor: Cray Inc.
Version: %{x_y_z}
Source: %{source_name}.tar.bz2
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}
Group: System/Management
License: MIT License
Summary: Dracut module for setting up an ephemeral disk as kubernetes container storage.

Requires: rpm
Requires: coreutils
Requires: dracut
Requires: dracut-metal-mdsquash
Requires: iputils

%define dracut_modules /usr/lib/dracut/modules.d
%define url_dracut_doc /usr/share/doc/dracut-metal-dmk8s/

%description

%prep

%setup

%build

%install
%{__mkdir_p} %{buildroot}%{dracut_modules}/98metaldmk8s
%{__mkdir_p} %{buildroot}%{url_dracut_doc}
%{__install} -m 0755 metal-dmk8s-disks.sh module-setup.sh metal-update-fstab.sh parse-metal-dmk8s.sh metal-dmk8s-lib.sh metal-dmk8s-genrules.sh %{buildroot}%{dracut_modules}/98metaldmk8s
%{__install} -m 0644 README.md %{buildroot}%{url_dracut_doc}

%files
%defattr(0755, root, root)
%license LICENSE
%dir %{dracut_modules}/98metaldmk8s
%{dracut_modules}/98metaldmk8s/*.sh
%dir %{url_dracut_doc}
%attr(644, root, root) %{url_dracut_doc}/README.md

%pre

%post

%preun

%changelog
