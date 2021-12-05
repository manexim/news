project('com.github.manexim.news', 'vala', 'c', version: '0.1.5')

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

dependencies = [
    dependency('gtk+-3.0'),
    dependency('granite'),
    dependency('libsoup-2.4'),
    dependency('libxml-2.0'),
    dependency('webkit2gtk-4.0'),
    dependency('gee-0.8'),
    dependency('libhandy-1', version: '>=1.0.0'),
]

subdir('data')
subdir('po')
subdir('src')

meson.add_install_script('meson/post_install.py')
