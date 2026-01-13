function mkicns -d "Create .icns file from a source image"
    if test (count $argv) -ne 1
        echo "Usage: mkicns <source-image.png|jpg>"
        return 1
    end

    set -l source_image $argv[1]

    if not test -f "$source_image"
        echo "Source image not found: $source_image"
        return 1
    end

    # Use the base name of the source image for the output files.
    set -l source_image_base (basename $source_image ".png")
    set -l iconset_dir "$source_image_base.iconset"

    # Create the iconset directory, removing the old one if it exists.
    if mkdir -p $iconset_dir
        echo "Creating iconset at: $iconset_dir"
    else
        echo "Error creating iconset directory: $iconset_dir"
    end

    # Generate all the required sizes using sips.
    sips -z 16 16 $source_image --out "$iconset_dir/icon_16x16.png" >/dev/null
    sips -z 32 32 $source_image --out "$iconset_dir/icon_16x16@2x.png" >/dev/null
    sips -z 32 32 $source_image --out "$iconset_dir/icon_32x32.png" >/dev/null
    sips -z 64 64 $source_image --out "$iconset_dir/icon_32x32@2x.png" >/dev/null
    sips -z 128 128 $source_image --out "$iconset_dir/icon_128x128.png" >/dev/null
    sips -z 256 256 $source_image --out "$iconset_dir/icon_128x128@2x.png" >/dev/null
    sips -z 256 256 $source_image --out "$iconset_dir/icon_256x256.png" >/dev/null
    sips -z 512 512 $source_image --out "$iconset_dir/icon_256x256@2x.png" >/dev/null
    sips -z 512 512 $source_image --out "$iconset_dir/icon_512x512.png" >/dev/null

    # The 1024px image is just a copy of the source.
    cp $source_image "$iconset_dir/icon_512x512@2x.png"

    echo "Iconset images prepped for conversion."

    read -P "Proceed with .icns conversion and cleanup? (y/N)" -n 1 -l response

    switch (string lower -- $response)
        case y
            echo "Converting iconset to .icns file..."
            if iconutil -c icns $iconset_dir
                echo "Cleaning up..."
                rm -rf $iconset_dir
                echo "$(set_color -o green)Done! Created $base_name.icns in the current directory.$(set_color normal)"
            else
                echo "Error converting iconset to .icns file."
                return 1
            end
        case '*'
            echo "Conversion step bypassed. The prepared iconset directory is ready for manual use."
            return 0
    end
end
