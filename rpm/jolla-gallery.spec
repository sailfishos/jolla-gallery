Name:       jolla-gallery
Summary:    Jolla Gallery application
Version:    0.2.10
Release:    1
License:    Proprietary
URL:        https://bitbucket.org/jolla/ui-jolla-gallery
Source0:    %{name}-%{version}.tar.bz2
Source1:    %{name}.privileges
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Gui)
BuildRequires:  pkgconfig(Qt5OpenGL)
BuildRequires:  pkgconfig(Qt5Network)
BuildRequires:  pkgconfig(Qt5Multimedia)
BuildRequires:  pkgconfig(Qt5Concurrent)
BuildRequires:  desktop-file-utils
BuildRequires:  pkgconfig(mlite5)
BuildRequires:  pkgconfig(Qt5DocGallery)
BuildRequires:  pkgconfig(qdeclarative5-boostable)
BuildRequires:  qt5-qttools
BuildRequires:  qt5-qttools-linguist
BuildRequires:  pkgconfig(libjollasignonuiservice-qt5)
BuildRequires:  pkgconfig(contentaction5)
BuildRequires:  oneshot

Requires:  ambient-icons-closed
Requires:  sailfishsilica-qt5 >= 1.1.53
Requires:  qt5-qtdocgallery
Requires:  mapplauncherd >= 4.1.17
Requires:  mapplauncherd-booster-silica-qt5
Requires:  qt5-qtdeclarative-import-multimedia
Requires:  declarative-transferengine-qt5 >= 0.0.49
Requires:  nemo-qml-plugin-thumbnailer-qt5-video
Requires:  nemo-qml-plugin-thumbnailer-qt5
Requires:  sailfish-components-media-qt5
Requires:  sailfish-components-gallery-qt5 >= 1.1.2
Requires:  ambienced
Requires:  %{name}-ambience >= 0.1.10
Requires:  jolla-settings-accounts >= 0.1.31
Requires:  nemo-qml-plugin-policy-qt5
Requires:  nemo-qml-plugin-dbus-qt5
%{_oneshot_requires_post}

%description
The Jolla Gallery application.

%package ts-devel
Summary:   Translation source for Jolla Gallery

%description ts-devel
%{summary}.

%package tests
Summary:    Unit tests for Jolla Gallery
BuildRequires:  pkgconfig(Qt5Test)
BuildRequires:  pkgconfig(Qt5DocGallery)
Requires:   %{name} = %{version}-%{release}
Requires:   qt5-qtdeclarative-import-qttest
Requires:   qt5-qtdeclarative-devel-tools
Requires:   dbus
Requires:   mce-tools

%description tests
This package contains QML unit tests for Jolla Gallery application.

%prep
%setup -q -n %{name}-%{version}

%build

%qmake5

make %{?_smp_mflags}

%install
rm -rf %{buildroot}
%qmake5_install
chmod +x %{buildroot}/opt/tests/%{name}/auto/run-tests.sh
chmod +x %{buildroot}/%{_oneshotdir}/*

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

mkdir -p %{buildroot}%{_datadir}/mapplauncherd/privileges.d
install -m 644 -p %{SOURCE1} %{buildroot}%{_datadir}/mapplauncherd/privileges.d/

%files
%defattr(-,root,root,-)
%{_datadir}/applications/*.desktop
%{_datadir}/%{name}
%{_bindir}/%{name}
%{_datadir}/translations/gallery_eng_en.qm
%{_datadir}/dbus-1/services/com.jolla.gallery.service
%{_datadir}/dbus-1/interfaces/com.jolla.gallery.xml
%{_datadir}/mapplauncherd/privileges.d/*
%{_libdir}/qt5/qml/com/jolla/gallery
%{_oneshotdir}/enable-gallery-hints

%files ts-devel
%defattr(-,root,root,-)
%{_datadir}/translations/source/gallery.ts

%files tests
%defattr(-,root,root,-)
/opt/tests/%{name}

%post -n %{name}
/sbin/ldconfig
/usr/bin/update-desktop-database -q || :
%{_bindir}/add-oneshot --new-users enable-gallery-hints || :

%postun -n %{name}
/sbin/ldconfig


