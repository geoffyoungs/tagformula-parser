require 'tagformula'
require 'strscan'

module Tagformula::Parser
	class Group
		def initialize()
			@contents = []
		end
		def empty?
			@contents.empty?
		end
		def last_entry
			@contents.last
		end
		def push_condition(what)
			if [:and,:or].include?(what) && (! @contents.last.is_a?(Symbol))
				@contents << what
			end
		end
		def push_entry(entry)
			case entry
			when Tag, Group
				@contents << entry
			end
		end
		def required_tags
			@contents.map do |content|
				if content.is_a?(Tag) && content.needed
					content.tagname
				elsif content.is_a?(Group)
					content.required_tags
				else
					nil
				end
			end.flatten.compact
		end
		def matches?(taglist)
			condition, op, i = nil, nil, 0
			while @contents[i]
				case @contents[i]
				when Symbol
					op = @contents[i]
				when Group, Tag
					res = @contents[i].matches?(taglist)
					raise "Epic fail - res is neither true nor false" unless [true,false].include?(res)
					case op
					when :and
						condition &&= res
					when :or
						condition ||= res
					when nil
						if i.zero?
							condition = res
						else
							raise "Epic fail - apparently no operator between tags.  How does this even happen?"
						end
					end
				else
					raise "Epic fail - invalid group entry" # epic fail
				end
				i += 1
			end
			condition
		end
	end
	class Tag
		attr_reader :tagname, :needed
		def initialize(tagname, needed)
			@tagname, @needed = tagname, needed
		end
		def matches?(taglist)
			case @tagname
			when 'true', 'false', 'yes', 'no'
				@needed
			else
				taglist.include?(@tagname) ? @needed : ! @needed
			end	
		end
	end
	module_function
	def parse(str)
		groups = [Group.new]
		scanner = StringScanner.new(str)
		until scanner.eos?
		last = groups.last.last_entry

		if scanner.scan(/\(/)
			raise SyntaxError, "Unexpected tag at #{scanner.pos} - #{scanner.peek(scanner.rest_size)}" unless last.nil? or last.is_a?(Symbol)
			push_group(groups)
		elsif scanner.scan(/\)/)
			raise SyntaxError, "Unexpected group end at #{scanner.pos} - #{scanner.peek(scanner.rest_size)}" if last.nil? or last.is_a?(Symbol)
			grp = pop_group(groups)
			raise SyntaxError, "Empty group at offset #{scanner.pos} - #{scanner.peek(scanner.rest_size)}" if grp.empty?
			raise SyntaxError, "Unmatched braces at offset #{scanner.pos} - #{scanner.peek(scanner.rest_size)}" if groups.empty?
		elsif scanner.scan(/([-0-9a-zA-Z.]+)/)
			raise SyntaxError, "Unexpected tag at #{scanner.pos} - #{scanner.peek(scanner.rest_size)}" unless last.nil? or last.is_a?(Symbol)
			push_tag(groups, scanner[1])
		elsif scanner.scan(/[!~]\s*([-0-9a-zA-Z.]+)/)
			raise SyntaxError, "Unexpected tag at #{scanner.pos} - #{scanner.peek(scanner.rest_size)}" unless last.nil? or last.is_a?(Symbol)
			push_not_tag(groups, scanner[1])
		elsif scanner.scan(/[,|]/)
			raise SyntaxError, "Unexpected operator at #{scanner.pos} - #{scanner.peek(scanner.rest_size)}" if last.is_a?(Symbol)
			push_or(groups)
		elsif scanner.scan(/[&+]/)
			raise SyntaxError, "Unexpected operator at #{scanner.pos} - #{scanner.peek(scanner.rest_size)}" if last.is_a?(Symbol)
			push_and(groups)
    elsif scanner.scan(/\s+/)
		else
			raise SyntaxError, "Error at offset #{scanner.pos} - #{scanner.peek(scanner.rest_size)}"
		end
		end
		raise SyntaxError, "Unmatched braces at offset #{scanner.pos} - #{scanner.peek(scanner.rest_size)}" if groups.size != 1
		groups[0]
	end
	class << self
	private
	def push_group(groups)
		group = Group.new
		groups.last.push_entry(group)
		groups.push(group)
	end
	def pop_group(groups)
		groups.pop()
	end
	def push_tag groups, tag
		groups.last.push_entry(Tag.new(tag, true))
	end
	def push_not_tag groups, tag
		groups.last.push_entry(Tag.new(tag, false))
	end
	def push_or groups
		groups.last.push_condition(:or)
	end
	def push_and groups
		groups.last.push_condition(:and)
	end
	end
end
