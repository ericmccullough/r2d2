# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Glyph.create([
               { name: 'glyphicon-unchecked' },
               { name: 'glyphicon-thumbs-up' },
               { name: 'glyphicon-thumbs-down' },
               { name: 'glyphicon-warning-sign' },
               { name: 'glyphicon-eye-open' },
               { name: 'glyphicon-star' }
              ])

List.create([
               { name: 'Unassigned', glyph_id: Glyph.find_by_name('glyphicon-unchecked').id },
               { name: 'Whitelist', glyph_id: Glyph.find_by_name('glyphicon-thumbs-up').id },
               { name: 'Blacklist', glyph_id: Glyph.find_by_name('glyphicon-thumbs-down').id }
            ])

Pref.create([
              { mac_separator: ':', mac_uppercase: true, mac_separators: ':-.' }
            ])

