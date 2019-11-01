project('com.github.manexim.news', 'vala', 'c')

gnome = import('gnome')

gtk_plus_3_dep = dependency('gtk+-3.0')
granite_dep = dependency('granite')
soup_dep = dependency('libsoup-2.4')
xml_dep = dependency('libxml-2.0')
webkit2gtk_4_dep = dependency('webkit2gtk-4.0')
gee_dep = dependency('gee-0.8')

dependencies = [
    gtk_plus_3_dep,
    granite_dep,
    soup_dep,
    xml_dep,
    webkit2gtk_4_dep,
    gee_dep
]

subdir('data')
subdir('src')

meson.add_install_script('meson/post_install.py')
