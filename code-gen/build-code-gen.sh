#!/bin/sh -e

# There is a bug that causes an infinite loop when building code-gen.
# https://bugs.eclipse.org/bugs/show_bug.cgi?id=489387
# The following is a hack to workaround it. If there is a simpler way, never tell me.

M2="/root/.m2/repository"
export JAVA_HOME="/tmp/jdk8u352-b08"
export PATH="${JAVA_HOME}/bin:${PATH}"

#### HACK STARTS HERE ####

echo "Downloading the buggy artifact..."
mvn --batch-mode --quiet org.apache.maven.plugins:maven-dependency-plugin:2.1:get \
    -DrepoUrl=https://download.eclipse.org/releases/photon   \
    -Dartifact=org.eclipse.tycho:org.eclipse.osgi:3.10.0.v20140606-1445

# Get the source code for the buggy part of the artifact above. Not sure about the version.
echo "Cloning source for the buggy artifact..."
git clone --quiet --depth 1 --branch I20140606-1215 https://eclipse.googlesource.com/equinox/rt.equinox.framework

# Fix the bug.
echo "Patching/compiling/packaging buggy code..."
cd rt.equinox.framework
git apply --ignore-whitespace <<EOF
--- a/bundles/org.eclipse.osgi/container/src/org/eclipse/osgi/internal/signedcontent/SignatureBlockProcessor.java
+++ b/bundles/org.eclipse.osgi/container/src/org/eclipse/osgi/internal/signedcontent/SignatureBlockProcessor.java
@@ -200,7 +200,7 @@ public class SignatureBlockProcessor implements SignedContentConstants {
                                if (aDigestLine != null) {
                                        String msgDigestAlgorithm = getDigestAlgorithmFromString(aDigestLine);
                                        if (!msgDigestAlgorithm.equalsIgnoreCase(signerInfo.getMessageDigestAlgorithm()))
-                                               continue; // TODO log error?
+                                               break; // TODO log error?
                                        byte digestResult[] = getDigestResultsList(aDigestLine);

                                        //
EOF

# Compile the patched class.
javac -cp "${M2}/org/eclipse/tycho/org.eclipse.osgi/3.10.0.v20140606-1445/org.eclipse.osgi-3.10.0.v20140606-1445.jar" \
    bundles/org.eclipse.osgi/container/src/org/eclipse/osgi/internal/signedcontent/SignatureBlockProcessor.java

# Replace the patched class.
cd bundles/org.eclipse.osgi/container/src
zip "${M2}/org/eclipse/tycho/org.eclipse.osgi/3.10.0.v20140606-1445/org.eclipse.osgi-3.10.0.v20140606-1445.jar" \
    org/eclipse/osgi/internal/signedcontent/SignatureBlockProcessor.class

# Hack to disable jar verification since it will fail on this patched class and I'm not sure how to update the digest in the jar.
zip -d "${M2}/org/eclipse/tycho/org.eclipse.osgi/3.10.0.v20140606-1445/org.eclipse.osgi-3.10.0.v20140606-1445.jar" \
    META-INF/ECLIPSE_.RSA
zip -d "${M2}/org/eclipse/tycho/org.eclipse.osgi/3.10.0.v20140606-1445/org.eclipse.osgi-3.10.0.v20140606-1445.jar" \
    META-INF/ECLIPSE_.SF

#### HACK STOPS HERE ####

# Clone and build code-gen.
cd /tmp
echo "Cloning code-gen..."
git clone --quiet --depth 1 https://github.com/TalendStuff/code-gen.git
cd code-gen
echo "Building code-gen..."
mvn --batch-mode --quiet clean package