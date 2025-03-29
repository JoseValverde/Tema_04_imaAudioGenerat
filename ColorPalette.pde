class ColorPalette {
  color[] colors = {
    #BFAE9F, #937962, #FFFFFF, #C9BEB9, 
    #978178, #4D4D4D, #9E9E9E, #F5EFE8, 
    #EEE3D7, #FFFFFF
  };
  
  color getBaseColor() {
    return colors[0];
  }
  
  color getHighlightColor() {
    return colors[int(random(colors.length))];
  }
}
