# Based on the devel/intellij port from OpenBSD by
# Vadim Zhukov <zhuk@openbsd.org>

PORTNAME=	intellij
PORTVERSION=	2023.2.2
CATEGORIES=	java devel
MASTER_SITES=	https://download.jetbrains.com/idea/
DISTNAME=	ideaIC-${PORTVERSION}
DIST_SUBDIR=	jetbrains

MAINTAINER=	vishwin@FreeBSD.org
COMMENT=	IntelliJ IDEA Community Edition
WWW=		https://www.jetbrains.com/idea/

LICENSE=	APACHE20

RUN_DEPENDS=	intellij-fsnotifier>0:java/intellij-fsnotifier

USES=		cpe python:run shebangfix
CPE_VENDOR=	jetbrains
CPE_PRODUCT=	${PORTNAME}_idea

USE_JAVA=	yes
JAVA_VERSION=	17+

SHEBANG_FILES=	bin/restart.py

NO_ARCH=	yes
NO_ARCH_IGNORE=	libjansi.so libjnidispatch.so
NO_BUILD=	yes

WRKSRC=		${WRKDIR}/idea-IC-232.9921.47

SUB_FILES=	idea idea.desktop pkg-message
CONFLICTS=	idea intellij-ultimate

do-install:
# Linux/Windows/OS X only so remove them
	@${RM} -r ${WRKSRC}/bin/fsnotifier \
		${WRKSRC}/bin/fsnotifier-arm \
		${WRKSRC}/bin/fsnotifier64 \
		${WRKSRC}/lib/pty4j-native/ \
		${WRKSRC}/plugins/android/lib/libwebp/ \
		${WRKSRC}/plugins/maven/lib/maven3/lib/jansi-native/linux32/ \
		${WRKSRC}/plugins/maven/lib/maven3/lib/jansi-native/linux64/ \
		${WRKSRC}/plugins/maven/lib/maven3/lib/jansi-native/osx/ \
		${WRKSRC}/plugins/maven/lib/maven3/lib/jansi-native/windows32/ \
		${WRKSRC}/plugins/maven/lib/maven3/lib/jansi-native/windows64/ \
		#${WRKSRC}/plugins/performanceTesting/bin/
	${MKDIR} ${STAGEDIR}${DATADIR}
	@(cd ${WRKSRC} && ${COPYTREE_SHARE} . ${STAGEDIR}${DATADIR} \
		"! -name *\.so ! -name *\.dll ! -name *\.dylib ! -name *\.pdb ! -name *\.sh")
	@(cd ${WRKSRC} && ${COPYTREE_BIN} . ${STAGEDIR}${DATADIR} "-name *\.sh")
	#${INSTALL_LIB} ${WRKSRC}/plugins/maven/lib/maven3/lib/jansi-native/freebsd32/libjansi.so \
	#	${STAGEDIR}${DATADIR}/plugins/maven/lib/maven3/lib/jansi-native/freebsd32/
	#${INSTALL_LIB} ${WRKSRC}/plugins/maven/lib/maven3/lib/jansi-native/freebsd64/libjansi.so \
	#	${STAGEDIR}${DATADIR}/plugins/maven/lib/maven3/lib/jansi-native/freebsd64/
	${INSTALL_SCRIPT} ${WRKDIR}/idea ${STAGEDIR}${PREFIX}/bin/idea
	${INSTALL_MAN} ${FILESDIR}/idea.1 ${STAGEDIR}${PREFIX}/man/man1
	${INSTALL_DATA} ${WRKDIR}/idea.desktop ${STAGEDIR}${PREFIX}/share/applications/
# Use fsnotifier replacement provided by java/intellij-fsnotifier
	${ECHO} "idea.filewatcher.executable.path=${PREFIX}/intellij/bin/fsnotifier" >> ${STAGEDIR}${DATADIR}/bin/idea.properties
# Fix "Typeahead timeout is exceeded" error
	${ECHO} "action.aware.typeAhead=false" >> ${STAGEDIR}${DATADIR}/bin/idea.properties
# Fix slow render
	${ECHO} "-Dsun.java2d.xrender=false" >> ${STAGEDIR}${DATADIR}/bin/idea.vmoptions
	${ECHO} "-Dsun.java2d.xrender=false" >> ${STAGEDIR}${DATADIR}/bin/idea64.vmoptions

.include <bsd.port.mk>
