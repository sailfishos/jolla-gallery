Name:       jolla-gallery
Summary:    Jolla Gallery application
Version:    0.0.15
Release:    1
Group:      Applications/Multimedia
License:    TBD
URL:        https://bitbucket.org/jolla/ui-jolla-gallery
Source0:    %{name}-%{version}.tar.bz2
BuildRequires:  pkgconfig(QtCore) >= 4.8.0
BuildRequires:  pkgconfig(QtDeclarative)
BuildRequires:  pkgconfig(QtGui)
BuildRequires:  pkgconfig(QtOpenGL)
BuildRequires:  desktop-file-utils
BuildRequires:  pkgconfig(mlite)
BuildRequires:  pkgconfig(QtGallery)
BuildRequires:  pkgconfig(qdeclarative-boostable)

Requires:  jollacomponents
Requires:  libdeclarative-gallery

%description
The Jolla Gallery application.

%prep
%setup -q -n %{name}-%{version}

%build

%qmake 

make %{?jobs:-j%jobs}

%install
rm -rf %{buildroot}
%qmake_install

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/applications/*.desktop
%{_datadir}/jolla-gallery/*
%{_bindir}/jolla-gallery

%post -n jolla-gallery -p /sbin/ldconfig
%postun -n jolla-gallery -p /sbin/ldconfig


