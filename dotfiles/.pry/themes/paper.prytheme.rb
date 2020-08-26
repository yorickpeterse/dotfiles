# frozen_string_literal: true
# rubocop: disable all

t = PryTheme.create name: 'paper' do
  author name: 'Yorick Peterse', email: 'yorick@yorickpeterse.com'
  description 'Pry theme based on https://gitlab.com/yorickpeterse/vim-paper'

  black = 0
  bold = [:bold]
  blue = '#1e6fcc'
  green = '#216609'
  orange = '#bf5c00'
  red = '#cc3e28'
  gray = '#777777'
  purple = '#5c21a5'

  define_theme do
    class_ black
    class_variable purple
    comment gray
    constant black
    error red
    float blue
    global_variable black
    inline_delimiter black
    instance_variable purple
    integer blue
    keyword bold
    method black
    predefined_constant black
    symbol orange

    regexp do
      self_ black
      char black
      content orange
      delimiter orange
      modifier orange
      escape black
    end

    shell do
      self_ black
      char black
      content green
      delimiter green
      escape black
    end

    string do
      self_ black
      char black
      content green
      delimiter green
      escape black
    end
  end
end

PryTheme::ThemeList.add_theme(t)
