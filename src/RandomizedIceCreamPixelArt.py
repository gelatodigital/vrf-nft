import random
from xml.etree import ElementTree as ET

svg_data = '''
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svgjs="http://svgjs.dev/svgjs" viewBox="0 0 800 800" preserveAspectRatio="xMidYMid slice">
  <defs>
    <pattern id="pppixelate-pattern" width="20" height="20" patternUnits="userSpaceOnUse" patternTransform="translate(0 0) scale(40) rotate(0)" shape-rendering="crispEdges">
<!--Color fill: hsl(50, 98%, 50%)-->
      <g fill="hsl(50, 98%, 50%)">
        <rect width="1" height="1" x="9" y="6"/>
        <rect width="1" height="1" x="10" y="6"/>
        <rect width="1" height="1" x="8" y="7"/>
        <rect width="1" height="1" x="9" y="7"/>
        <rect width="1" height="1" x="10" y="7"/>
        <rect width="1" height="1" x="8" y="8"/>
        <rect width="1" height="1" x="9" y="8"/>
        <rect width="1" height="1" x="9" y="9"/>
      </g>
<!--Color fill: hsl(335, 77%, 50%)-->
      <g fill="hsl(335, 77%, 50%)">
        <rect width="1" height="1" x="7" y="7"/>
        <rect width="1" height="1" x="6" y="8"/>
        <rect width="1" height="1" x="7" y="8"/>
        <rect width="1" height="1" x="6" y="9"/>
        <rect width="1" height="1" x="7" y="9"/>
        <rect width="1" height="1" x="8" y="9"/>
      </g>
<!--Color fill: hsl(352, 100%, 76%)-->
      <g fill="hsl(352, 100%, 76%)">
          <rect width="1" height="1" x="11" y="7"/>
          <rect width="1" height="1" x="12" y="7"/>
          <rect width="1" height="1" x="10" y="8"/>
          <rect width="1" height="1" x="11" y="8"/>
          <rect width="1" height="1" x="12" y="8"/>
          <rect width="1" height="1" x="13" y="8"/>
          <rect width="1" height="1" x="10" y="9"/>
          <rect width="1" height="1" x="11" y="9"/>
          <rect width="1" height="1" x="12" y="9"/>
          <rect width="1" height="1" x="13" y="9"/>
      </g>
<!--Color fill: hsl(10, 75%, 40%)-->
      <g fill="hsl(10, 75%, 40%)">
        <rect width="1" height="1" x="6" y="10"/>
        <rect width="1" height="1" x="8" y="10"/>
        <rect width="1" height="1" x="10" y="10"/>
        <rect width="1" height="1" x="12" y="10"/>
        <rect width="1" height="1" x="7" y="11"/>
        <rect width="1" height="1" x="9" y="11"/>
        <rect width="1" height="1" x="11" y="11"/>
        <rect width="1" height="1" x="8" y="12"/>
        <rect width="1" height="1" x="10" y="12"/>
        <rect width="1" height="1" x="9" y="13"/>
        <rect width="1" height="1" x="11" y="13"/>
        <rect width="1" height="1" x="12" y="12"/>
        <rect width="1" height="1" x="10" y="14"/>
        <rect width="1" height="1" x="9" y="15"/>
        <rect width="1" height="1" x="8" y="14"/>
        <rect width="1" height="1" x="10" y="16"/>
      </g>
<!--Color fill: hsl(30, 100%, 40%)-->
      <g fill="hsl(30, 100%, 40%)">
        <rect width="1" height="1" x="7" y="10"/>
        <rect width="1" height="1" x="9" y="10"/>
        <rect width="1" height="1" x="11" y="10"/>
        <rect width="1" height="1" x="13" y="10"/>
        <rect width="1" height="1" x="8" y="11"/>
        <rect width="1" height="1" x="10" y="11"/>
        <rect width="1" height="1" x="12" y="11"/>
        <rect width="1" height="1" x="7" y="12"/>
        <rect width="1" height="1" x="9" y="12"/>
        <rect width="1" height="1" x="11" y="12"/>
        <rect width="1" height="1" x="8" y="13"/>
        <rect width="1" height="1" x="10" y="13"/>
        <rect width="1" height="1" x="9" y="14"/>
        <rect width="1" height="1" x="11" y="14"/>
        <rect width="1" height="1" x="10" y="15"/>
        <rect width="1" height="1" x="9" y="16"/>
      </g>
    </pattern>
  </defs>
  <rect width="100%" height="100%" fill="url(#pppixelate-pattern)"/>
</svg>
'''

def random_hsl_color():
    h = random.randint(0, 360)
    s = random.randint(50, 100)  # Keeping saturation and lightness a bit limited for better colors
    l = random.randint(40, 60)
    return f"hsl({h}, {s}%, {l}%)"

def randomize_svg_colors(svg_data):
    # Parse the SVG
    root = ET.fromstring(svg_data)
    
    # SVG namespace
    ns = {"svg": "http://www.w3.org/2000/svg"}
    
    # Fetch all <g> elements within the pattern using the namespace
    for group in root.findall(".//svg:pattern[@id='pppixelate-pattern']/svg:g", ns):
        color = random_hsl_color()
        # For each rectangle inside the group, set the fill color
        for rect in group.findall("svg:rect", ns):
            rect.set('fill', color)

    # Serialize the SVG back to string format
    return ET.tostring(root, encoding="unicode")


randomized_svg = randomize_svg_colors(svg_data)
print(randomized_svg)
