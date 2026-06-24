# Downloads missing AGP 8.3.1 transitive JARs from Google Maven into a local Maven repo.
# Run this script when the Gradle JVM can't reach dl.google.com but PowerShell can.
# After running, a Gradle init script picks up the local repo automatically.

$localMaven = "$env:USERPROFILE\.gradle\local-maven"
$baseUrl = "https://dl.google.com/dl/android/maven2"

$artifacts = @(
    "com.android.tools.utp:android-device-provider-ddmlib-proto:31.3.1",
    "com.android.tools.utp:android-device-provider-gradle-proto:31.3.1",
    "com.android.tools.utp:android-test-plugin-host-additional-test-output-proto:31.3.1",
    "com.android.tools.utp:android-test-plugin-host-apk-installer-proto:31.3.1",
    "com.android.tools.utp:android-test-plugin-host-coverage-proto:31.3.1",
    "com.android.tools.utp:android-test-plugin-host-emulator-control-proto:31.3.1",
    "com.android.tools.utp:android-test-plugin-host-logcat-proto:31.3.1",
    "com.android.tools.utp:android-test-plugin-host-retention-proto:31.3.1",
    "com.android.tools.utp:android-test-plugin-result-listener-gradle-proto:31.3.1",
    "com.android.tools:annotations:31.3.1",
    "com.android.tools.build:apksig:8.3.1",
    "com.android.tools.build:apkzlib:8.3.1",
    "com.android.databinding:baseLibrary:8.3.1",
    "com.android.tools.build:builder-model:8.3.1",
    "com.android.tools:common:31.3.1",
    "com.android.tools.analytics-library:crash:31.3.1",
    "androidx.databinding:databinding-common:8.3.1",
    "androidx.databinding:databinding-compiler-common:8.3.1",
    "com.android.tools.ddms:ddmlib:31.3.1",
    "com.android.tools:dvlib:31.3.1",
    "com.android.tools.build:gradle:8.3.1",
    "com.android.tools.layoutlib:layoutlib-api:31.3.1",
    "com.android.tools.lint:lint-typedef-remover:31.3.1",
    "com.android.tools.analytics-library:protos:31.3.1",
    "com.android.tools.analytics-library:shared:31.3.1",
    "com.android:signflinger:8.3.1",
    "com.android.tools.analytics-library:tracker:31.3.1",
    "com.android:zipflinger:8.3.1"
)

foreach ($coord in $artifacts) {
    $parts   = $coord -split ":"
    $group   = $parts[0]
    $artifact = $parts[1]
    $version = $parts[2]

    $groupPath = $group -replace "\.", "/"
    $destDir   = "$localMaven\$groupPath\$artifact\$version"
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null

    foreach ($ext in @("pom", "jar")) {
        $filename = "$artifact-$version.$ext"
        $destFile = "$destDir\$filename"
        if (Test-Path $destFile) {
            Write-Host "SKIP  $filename (already present)"
            continue
        }
        $url = "$baseUrl/$groupPath/$artifact/$version/$filename"
        try {
            Invoke-WebRequest -Uri $url -OutFile $destFile -UseBasicParsing -ErrorAction Stop
            Write-Host "OK    $filename"
        } catch {
            Write-Warning "FAIL  $filename : $($_.Exception.Message)"
            if (Test-Path $destFile) { Remove-Item $destFile }
        }
    }
}

Write-Host "`nDone. Local Maven repo at: $localMaven"
