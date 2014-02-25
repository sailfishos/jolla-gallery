Name:       jolla-gallery
Summary:    Jolla Gallery application
Version:    0.1.43
Release:    1
Group:      Applications/Multimedia
License:    TBD
URL:        https://bitbucket.org/jolla/ui-jolla-gallery
Source0:    %{name}-%{version}.tar.bz2
Source1:    rpmlintrc
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

Requires:  ambient-icons-closed
Requires:  sailfishsilica-qt5 >= 0.10.21
Requires:  qt5-qtdocgallery
Requires:  mapplauncherd-booster-silica-qt5
Requires:  qt5-qtdeclarative-import-multimedia
Requires:  declarative-transferengine-qt5
Requires:  nemo-qml-plugin-accounts-qt5
Requires:  nemo-qml-plugin-thumbnailer-qt5-video
Requires:  nemo-qml-plugin-thumbnailer-qt5
Requires:  sailfish-components-accounts-qt5
Requires:  sailfish-components-media-qt5
Requires:  sailfish-components-gallery-qt5 >= 0.0.39
Requires:  ambienced
Requires:  jolla-gallery-ambience
Requires:  jolla-gallery-facebook
Requires:  jolla-settings-accounts >= 0.1.31
Requires:  nemo-qml-plugin-policy-qt5

%description
The Jolla Gallery application.

%package ts-devel
Summary:   Translation source for Jolla Gallery
License:   TBD
Group:     Applications/Multimedia

%description ts-devel
Translation source for Jolla Gallery

%package tests
Summary:    Unit tests for Jolla Gallery
Group:      Applications/Multimedia
BuildRequires:  pkgconfig(Qt5Test)
BuildRequires:  pkgconfig(Qt5DocGallery)
Requires:   %{name} = %{version}-%{release}
Requires:   qt5-qtdeclarative-import-qttest
Requires:   qt5-qtdeclarative-devel-tools

%description tests
This package contains QML unit tests for Jolla Gallery application

%prep
%setup -q -n %{name}-%{version}

%build

%qmake5

make %{_smp_mflags}

%install
rm -rf %{buildroot}
%qmake5_install
chmod +x %{buildroot}/opt/tests/jolla-gallery/auto/run-tests.sh

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/applications/*.desktop
%{_datadir}/jolla-gallery/*
%{_bindir}/jolla-gallery
%{_datadir}/translations/gallery_eng_en.qm
%{_datadir}/dbus-1/services/com.jolla.gallery.service
%{_datadir}/dbus-1/interfaces/com.jolla.gallery.xml
%{_libdir}/qt5/qml/com/jolla/gallery/*.qml
%{_libdir}/qt5/qml/com/jolla/gallery/qmldir


%files ts-devel
%defattr(-,root,root,-)
%{_datadir}/translations/source/gallery.ts

%files tests
%defattr(-,root,root,-)
# >> files tests
/opt/tests/jolla-gallery/*
# << files tests

%post -n jolla-gallery
/sbin/ldconfig
/usr/bin/update-desktop-database -q

%postun -n jolla-gallery
/sbin/ldconfig


