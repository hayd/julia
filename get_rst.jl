using PyCall
@pyimport pypandoc

function extract(lines::Vector)
   i = 1
   items = []
   while i < length(lines)
       start, fin, headers = get_headers(lines, i)
       dedent = length(headers[:typ]) > 0
       headers[:contents] = get_contents(lines, start, fin; dedent=dedent)

       push!(items, headers)
       i = fin + 1
   end
   items
end

function get_contents(lines, start, fin; dedent=true)
   if dedent
       indent = get_indent(lines[start:fin])
           
        dedented = [line[min(indent, length(line)):end]
                    for line in lines[start:fin]]
   else
       dedented = lines[start:fin]
   end

   if any([startswith(line, ".. ") for line in dedented])
       return extract(dedented)
   else
       return [join(dedented)]
   end
end

function get_indent(lines)
    for line in lines
        if strip(line) != ""
            for (i, char) in enumerate(line)
                if char != ' '
                    return i
                end
            end
        end
    end
    return 1
end


function get_headers(lines, i)
   typ = []
   items = []
   while i < length(lines)
       line = lines[i]
       if strip(line) == ""
       elseif startswith(line, ".. ")
           t, item = split(line[3:end], "::"; limit=2)
           t = strip(t)
           if !(t in typ)
               push!(typ, t)
           end
           push!(items, strip(item))
       elseif startswith(line, " " ^ (5 + length(typ)))
           push!(items, strip(line[5 + length(typ):end]))
       elseif length(typ) == 0
           break
       else
           i -= 1; break
       end
       i += 1
   end
   start = i
   if length(typ) > 0
       while i < length(lines)
           line = lines[i]
           if strip(line[1:min(3, length(line))]) != ""
               i -= 1; break
           end
           i += 1
       end
   else
       while i < length(lines)
           line = lines[i]
           if startswith(line, ".. ")
               i-= 1; break
           end
           i += 1
       end
   end
   return start, i, Dict(:typ => typ, :items => items)
end

function parse(s::String)
    lines = readlines(open(s))
    lines = [replace(line, '\t', "    ") for line in lines]
    e = extract(lines)
    for item in e
        _markdown_contents!(item)
   end
   e
end

function _markdown_contents!(item)
    if isa(item, Dict) 
        for i in item[:contents]
            _markdown_contents!(i)
        end
    println(item)
    println()
    if item[:typ] == ["doctest"]
        item[:contents] = ["```doctest\n$(join(item[:contents], '\n'))```"]
    else
        println("tems")
        println(item)
        item[:contents] = [join([(isa(i, Dict) ?
                                  join(i[:contents], '\n') :
                                  pypandoc.convert(i, to="md", format="rst",
                                        extra_args=("-tmarkdown_github",)))
                           for i in item[:contents]], '\n')]
                                            #to="md", format="rst",
                                            #extra_args=("-tmarkdown_github",))]
    end
end
end

function make_doc(s::String)
    open("doc_$s.jl", "w") do f
        for item in parse("doc/stdlib/$s.rst")[1:20]
            if length(item[:contents]) == 0
                continue

            elseif length(item[:items]) == 1
                print(f, "@doc \"\"\"")
                print(f, join(item[:contents]))
                print(f, "\"\"\" ")
                println(f, join(item[:items]))

            elseif length(item[:items]) > 1
                print(f, "s = doc\"\"\"")
                print(f, join(item[:contents]))
                println(f, "\"\"\" ")
                print(f, "for f in [")
                for name in item[:items]
                    print(f, name, ", ")
                end
                println(f, "]")
                println(f, "    @doc s f")
                println(f, "end")

            else
                for line in split(join(item[:contents]), "\n")
                    println(f, "# ", line)
                end
            end
            println(f)
        end
    end
end
