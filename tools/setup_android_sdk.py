import os
import sys
import urllib.request
import zipfile
import shutil
import subprocess

sys.stdout.reconfigure(encoding='utf-8')

sdk_root = r'C:\Users\alimo\AppData\Local\Android\sdk'
cmdline_dir = os.path.join(sdk_root, 'cmdline-tools')
latest_dir = os.path.join(cmdline_dir, 'latest')
zip_path = os.path.join(sdk_root, 'cmdline-tools.zip')

os.makedirs(cmdline_dir, exist_ok=True)

url = 'https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip'
if not os.path.exists(os.path.join(latest_dir, 'bin', 'sdkmanager.bat')):
    if not os.path.exists(zip_path):
        print(f"Downloading Android Command-Line Tools (~140MB)...")
        sys.stdout.flush()
        urllib.request.urlretrieve(url, zip_path)
        print("Download complete.")
    else:
        print("Zip already exists.")

    print("Extracting...")
    sys.stdout.flush()
    temp_extract = os.path.join(sdk_root, 'temp_cmdline')
    if os.path.exists(temp_extract):
        shutil.rmtree(temp_extract)

    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(temp_extract)

    extracted_sub = os.path.join(temp_extract, 'cmdline-tools')
    if os.path.exists(latest_dir):
        shutil.rmtree(latest_dir)
    shutil.move(extracted_sub, latest_dir)
    shutil.rmtree(temp_extract)
    if os.path.exists(zip_path):
        os.remove(zip_path)

print(f"Android Command-Line Tools ready at {latest_dir}")
sdkmanager = os.path.join(latest_dir, 'bin', 'sdkmanager.bat')

# Configure flutter
print("Configuring Flutter Android SDK path...")
subprocess.run(['flutter', 'config', '--android-sdk', sdk_root], shell=True)

# Install platforms and build-tools
print("Installing platform-tools, platforms;android-34, build-tools;34.0.0...")
sys.stdout.flush()
# Pre-pipe 'y' to accept licenses
p = subprocess.Popen([sdkmanager, "--sdk_root=" + sdk_root, "platform-tools", "platforms;android-34", "build-tools;34.0.0"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
out, _ = p.communicate(input='y\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\n')
print(out[-800:] if len(out) > 800 else out)

# Accept flutter licenses
print("Accepting flutter licenses...")
subprocess.run(['flutter', 'doctor', '--android-licenses'], input=b'y\ny\ny\ny\ny\ny\ny\ny\n', shell=True)

print("Android SDK setup complete!")
