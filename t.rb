#!/usr/bin/env ruby

class MdLink
  def initialize(link, target)
    @link, @target = link, target
  end
  def to_s
    "[#{link}](#{target})"
  end
end

class MdTable
  def initialize
    @rows = []
  end
  def add_row(r)
    @rows << r
  end
  def to_md
    out = ""
    @rows.each_with_index do |row, index|
      row.each { |col| out += "| #{col} " }
      out += "|\n"
      if index == 0
        row.length.times { out += "|---" }
        out += "|\n"
      end
    end
    return out
  end
end

def test
  m = MdTable.new()
  m.add_row([ "price", "year" ])
  m.add_row([ "11", "2015" ])
  print m.to_md
end
