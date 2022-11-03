# formatting plots

# Default formatting ---- 


# Set theme universally : format as classic, colours = Set1

theme_set(theme_classic()) # theme classic ---- Disabled this since the scatter plots looked better with the gray
scale_colour_discrete <- function(...) { # default palette for colour
  scale_colour_brewer(..., palette="Dark2")
}

scale_fill_discrete <- function(...) { # default palette for fill
  scale_fill_brewer(..., palette="Dark2")
}


# Functions for formatting ----

# plot formatting function : format as classic, colours = Set1
format_classic <- function(plt)
{ # formats plot as classic, with colour palette Set1, centred title, angled x axis labels
  plt <- plt + 
    theme(legend.position = 'top') +  # position legend on the top
    theme_classic() + scale_color_brewer(palette="Set1") # set plain background theme, and colour scheme
}

# plot formatting function : format as logscale
format_logscale_y <- function(plt)
{ # extra comments
  plt <- {plt +
    scale_y_log10(  # logscale for y axis with tick marks
      labels = fancy_scientific
      #labels = scales::trans_format("log10", scales::math_format(10^.x) )
    )} %>% print()
}

# plot formatting function : format as logscale x
format_logscale_x <- function(plt)
{ # extra comments
  plt <- {plt +
    scale_x_log10(  # logscale for y axis with tick marks
      labels = fancy_scientific
      #labels = scales::trans_format("log10", scales::math_format(10^.x) )
    )} %>% 
    print()
}


# formatting labels in logscale cleanly : a x 10^b
fancy_scientific <- function(l) {
  # turn in to character string in scientific notation
  l <- format(l, scientific = TRUE)
  # quote the part before the exponent to keep all the digits
  l <- gsub("^(.*)e", "'\\1'e", l)
  # remove + after exponent, if exists. E.g.: (3x10^+2 -> 3x10^2) 
  l <- gsub("e\\+","e",l)
  # turn the 'e+' into plotmath format
  l <- gsub("e", "%*%10^", l)
  # convert 1x10^ or 1.000x10^ -> 10^ 
  l <- gsub("\\'1[\\.0]*\\'\\%\\*\\%", "", l)
  # return this as an expression
  parse(text=l)
}

# use as ggplot(df,aes(x,y)) + geom_point() + scale_y_log10(labels = fancy_scientific)

