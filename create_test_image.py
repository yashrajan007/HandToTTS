from PIL import Image, ImageDraw

# Create a simple test image with text
img = Image.new('RGB', (400, 200), color='white')
draw = ImageDraw.Draw(img)

# Add some sample text
text = 'OCR Test Image\nHello World\n2026-02-07'
draw.text((20, 50), text, fill='black')

# Save it
img.save('test_image.jpg')
print('✓ Test image created: test_image.jpg')
