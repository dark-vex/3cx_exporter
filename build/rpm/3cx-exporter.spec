%global debug_package %{nil}
%define _build_id_links none

%global user %{name}
%global group %{name}

%ifarch x86_64
%global rid x64
%endif

%ifarch aarch64
%global rid arm64
%endif

Name:           3cx-exporter
Version:        0.1.0
Release:        1
Summary:        3CX Prometheus metrics exporter
License:        MIT License
URL:            https://github.com/dark-vex/3cx_exporter

BuildArch:      x86_64 aarch64

Source0:        %{name}
Source10:       %{name}.service
Source11:       %{name}.json

BuildRequires:  systemd

%if 0%{?rhel} >= 8 || 0%{?fedora}
Requires:       (%{name}-selinux if selinux-policy)
%endif

%description
Prometheus exporter for 3CX PBX

%install
mkdir -p %{buildroot}/%{_bindir}

install -D -m 0644 %{name} %{buildroot}%{_bindir}/%{name}
install -D -m 0644 %{name}.service %{buildroot}%{_unitdir}/%{name}.service
install -D -m 0644 config.json %{buildroot}%{_sysconfdir}/3cx_exporter/config.json

%pre

%post
%systemd_post %{name}.service

%preun
%systemd_preun %{name}.service

%postun
%systemd_postun_with_restart %{name}.service

%files
%license LICENSE.md
%doc README.md
%{_bindir}/%{name}
%{_unitdir}/%{name}.service
%{_sysconfdir}/3cx_exporter/config.json

%changelog
* Mon Nov 14 2022 Daniele De Lorenzi <github@fastnetserv.net> - 0.1.0
- First release 0.1.0.
