Name:       jolla-gallery
Summary:    Jolla Gallery application
Version:    0.0.53
Release:    1
Group:      Applications/Multimedia
License:    TBD
URL:        https://bitbucket.org/jolla/ui-jolla-gallery
Source0:    %{name}-%{version}.tar.bz2
BuildRequires:  pkgconfig(QtCore) >= 4.8.0
BuildRequires:  pkgconfig(QtDeclarative)
BuildRequires:  pkgconfig(QtGui)
BuildRequires:  pkgconfig(QtOpenGL)
BuildRequires:  pkgconfig(QtNetwork)
BuildRequires:  desktop-file-utils
BuildRequires:  pkgconfig(mlite)
BuildRequires:  pkgconfig(QtGallery)
BuildRequires:  pkgconfig(qdeclarative-boostable)

Requires:  ambient-icons-closed
Requires:  sailfishsilica
Requires:  libdeclarative-gallery
Requires:  mapplauncherd-booster-jolla
Requires:  libdeclarative-multimedia
Requires:  declarative-transferengine => 0.0.12
Requires:  nemo-qml-plugins-accounts
Requires:  nemo-qml-plugins-gstvideo-thumbnailer
Requires:  nemo-qml-plugins-thumbnailer
Requires:  jolla-gallery-facebook

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
BuildRequires:  pkgconfig(QtTest)
BuildRequires:  pkgconfig(QtGallery)
Requires:   %{name} = %{version}-%{release}
Requires:   qtest-qml

%description tests
This package contains QML unit tests for Jolla Gallery application

%prep
%setup -q -n %{name}-%{version}

%build

%qmake 

make %{?jobs:-j%jobs}

%install
rm -rf %{buildroot}
%qmake_install
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

%files ts-devel
%defattr(-,root,root,-)
%{_datadir}/translations/source/gallery.ts

%files tests
%defattr(-,root,root,-)
# >> files tests
/opt/tests/jolla-gallery/*
# << files tests

%post -n jolla-gallery -p /sbin/ldconfig
%postun -n jolla-gallery -p /sbin/ldconfig


