import os
from PIL import Image

SOURCE_IMAGE = r"C:\Users\Mohsin\.gemini\antigravity\brain\6ad67798-6c03-4f9d-8344-6ed9c82105cd\maher_app_logo_1790394900742.jpg"
WORKSPACE = r"D:\Web-Work\Maher-quiz"

def generate_icons():
    if not os.path.exists(SOURCE_IMAGE):
        print(f"Error: Source image not found at {SOURCE_IMAGE}")
        return

    img = Image.open(SOURCE_IMAGE)
    print(f"Loaded source image: {img.size}, mode: {img.mode}")

    # Ensure RGBA
    if img.mode != "RGBA":
        img = img.convert("RGBA")

    # 1. Save high-res asset
    os.makedirs(os.path.join(WORKSPACE, "assets", "images"), exist_ok=True)
    asset_path = os.path.join(WORKSPACE, "assets", "images", "app_logo.png")
    img.resize((1024, 1024), Image.LANCZOS).save(asset_path, "PNG")
    print(f"Saved asset: {asset_path}")

    # 2. Android Mipmap Icons
    android_res = os.path.join(WORKSPACE, "android", "app", "src", "main", "res")
    android_sizes = {
        "mipmap-mdpi": (48, 48),
        "mipmap-hdpi": (72, 72),
        "mipmap-xhdpi": (96, 96),
        "mipmap-xxhdpi": (144, 144),
        "mipmap-xxxhdpi": (192, 192),
    }

    for folder, size in android_sizes.items():
        folder_path = os.path.join(android_res, folder)
        os.makedirs(folder_path, exist_ok=True)
        out_file = os.path.join(folder_path, "ic_launcher.png")
        resized = img.resize(size, Image.LANCZOS)
        resized.save(out_file, "PNG")
        print(f"Generated Android icon: {out_file} ({size[0]}x{size[1]})")

    # 3. iOS Icons
    ios_res = os.path.join(WORKSPACE, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    ios_sizes = {
        "Icon-App-20x20@1x.png": (20, 20),
        "Icon-App-20x20@2x.png": (40, 40),
        "Icon-App-20x20@3x.png": (60, 60),
        "Icon-App-29x29@1x.png": (29, 29),
        "Icon-App-29x29@2x.png": (58, 58),
        "Icon-App-29x29@3x.png": (87, 87),
        "Icon-App-40x40@1x.png": (40, 40),
        "Icon-App-40x40@2x.png": (80, 80),
        "Icon-App-40x40@3x.png": (120, 120),
        "Icon-App-60x60@2x.png": (120, 120),
        "Icon-App-60x60@3x.png": (180, 180),
        "Icon-App-76x76@1x.png": (76, 76),
        "Icon-App-76x76@2x.png": (152, 152),
        "Icon-App-83.5x83.5@2x.png": (167, 167),
        "Icon-App-1024x1024@1x.png": (1024, 1024),
    }

    if os.path.exists(ios_res):
        for filename, size in ios_sizes.items():
            out_file = os.path.join(ios_res, filename)
            resized = img.resize(size, Image.LANCZOS)
            resized.save(out_file, "PNG")
            print(f"Generated iOS icon: {out_file} ({size[0]}x{size[1]})")

    print("All icons generated successfully!")

if __name__ == "__main__":
    generate_icons()
