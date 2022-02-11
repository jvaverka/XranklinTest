using Dates

# using Dates
# import Franklin
# using Weave
#
# function hfun_bar(vname)
#     val = Meta.parse(vname[1])
#     return round(sqrt(val); digits=2)
# end
#
# function hfun_m1fill(vname)
#     var = vname[1]
#     return pagevar("index", var)
# end
#
# function lx_baz(com, _)
#     # keep this first line
#     brace_content = Franklin.content(com.braces[1]) # input string
#     # do whatever you want here
#     return uppercase(brace_content)
# end
#
# function hfun_eval(arg)
#     x = Core.eval(Franklin, Meta.parse(join(arg)))
#     io = IOBuffer()
#     show(io, "text/plain", x)
#     return String(take!(io))
# end
#

function write_posts(rpaths)::String
    sort_posts!(rpaths)
    curyear = Dates.year(pagevar(rpaths[1], :date))
    io = IOBuffer()
    write(io, "<h3 class=\"posts\">$curyear</h3>")
    write(io, "<ul class=\"posts\">")
    for rp in rpaths
        year = Dates.year(pagevar(rp, :date))
        if year < curyear
            write(io, "<h3 class=\"posts\">$year</h3>")
            curyear = year
        end
        title = pagevar(rp, :title)
        descr = pagevar(rp, :descr)
        pubdate = Dates.format(Date(pagevar(rp, :date)), "U d")
        path = joinpath(splitpath(rp)[1:2]...)
        write(
            io,
            """
            <li class="post">
              <p>
                <span class="post">$pubdate</span>
                <a class="post" href="/$path/">$title</a>
                <span class="post-descr tag">$descr</span>
              </p>
            </li>
            """,
        )
    end
    write(io, "</ul>")  #= posts =#
    return String(take!(io))
end


function sort_posts!(rpaths)
    sorter(p) = pagevar(p, :date)
    return sort!(rpaths; by=sorter, rev=true)
end


function hfun_allposts()::String
    jp(p) = joinpath("posts", p)
    rpaths = [
        joinpath(jp(p), "index.md") for
        p in readdir("posts") if isdir(jp(p))
    ]
    return write_posts(rpaths)
end


function hfun_alltags()
    # dictionary {id => Xranklin.Tag}
    # Tag has fields
    #   id (e.g. "the_tag")
    #   name (e.g. "The Tag")
    #   locs (list of rpaths with this tag)
    all_tags   = get_all_tags()
    tag_prefix = getgvar(:tags_prefix, "tag")

    io = IOBuffer()
    write(io, "<div class=\"tag-container\">")

    for tag_id in keys(all_tags)
        tag_name   = all_tags[tag_id].name
        n_with_tag = length(all_tags[tag_id].locs)
        write(io,
            """
            <div class="tag">
              <nobr>
                <a class="tag" href="/$tag_prefix/$tag_id/">
                  $(tag_name)
                  <span style="color:var(--color-grey-dark)">(</span>
                  <span style="color:var(--color-yellow)">$n_with_tag</span>
                  <span style="color:var(--color-grey-dark)">)</span>
                </a>
              </nobr>
            </div>
            """,
        )
    end

    write(io, "</div>")
    return String(take!(io))
end


# NOTE: this is now an internal function; you could overwrite it with your own
# stuff but let's wait a bit for now

# function hfun_taglist()
#     tag = Franklin.locvar(:fd_tag)::String
#     rpaths = Franklin.globvar("fd_tag_pages")[tag]
#     return write_posts(rpaths)
# end

#
# function hfun_weave2html(document)
#     f_name = tempname(pwd()) * ".html"
#     weave(first(document); out_path=f_name)
#     text = read(f_name, String)
#     final = x ->
#         replace(x, r"<span class='hljl-.*?>" => "") |> # Removes weave code block syntax
#         x ->
#             replace(x, "</span>" => "") |> # Removes weave code block syntax
#             x ->
#                 replace(
#                     x,
#                     "<pre class='hljl'>\n" => "<pre><code class = \"language-julia\">", # Replaces weave code block syntax with Franklin's
#                 ) |> x -> replace(x, "</pre>" => "</code></pre>")("<!DOCTYPE html>\n<HTML lang = \"en\">" *
#                                                                   split(text, "</HEAD>")[2]) # Replaces weave code block syntax with Franklin's
#     rm(f_name)
#     return final
# end
#

function hfun_posttags()
    tags = get_page_tags()
    base = globvar(:tags_prefix)
    return """<div class="page-tag"><i class="fa fa-tag"></i>""" *
        join((
            """
            <span class="tag">
              <a href="/$base/$id/">$name</a>
            </span>
            """
            for (id, name) in tags),
            """<span class="separator">•</span>"""
        ) *
        """</div>"""
end


function hfun_socialicons()
    """
    <div class="social-container">
        <div class="social-icon">
            <a href="/posts/" title="Blog">
                <i class="fa fa-pencil"></i>
            </a>
        </div>
        <div class="social-icon">
            <a href="/about/" title="About">
                <i class="fa fa-user-circle-o"></i>
            </a>
        </div>
        <div class="social-icon">
            <a href="/feed.xml" title="RSS">
                <i class="fa fa-rss"></i>
            </a>
        </div>
        <div class="social-icon">
            <a href="https://gitlab.com/jvaverka" title="GitLab">
                <i class="fa fa-gitlab" aria-hidden="false"></i>
            </a>
        </div>
        <div class="social-icon">
            <a href="https://github.com/jvaverka" title="GitHub">
                <i class="fa fa-github"></i>
            </a>
        </div>
        <div class="social-icon">
            <a href="https://www.linkedin.com/in/jacob-vaverka-b5965052" title="LinkedIn">
                <i class="fa fa-linkedin"></i>
            </a>
        </div>
    </div>
    """
end

#
# """
#     newpost(;title::String, descr::String, tags::Vector{String}, code=false)
# """
# function newpost(;title::String, descr::String, tags::Vector{String}, code=false)
#     path = joinpath(@__DIR__, "posts", replace(lowercase(title), " " => "-"))
#     post = joinpath(path, "index.md")
#     mkpath(path)
#     touch(post)
#     y = Dates.year(Dates.today())
#     m = Dates.month(Dates.today())
#     d = Dates.day(Dates.today())
#     open(post, "w") do io
#         write(io, """
#         +++
#         title = "$title"
#         descr = "$descr"
#         rss = "$descr"
#         date = Date($y, $m, $d)
#         hascode = $code
#         tags = $(sort(tags))
#         +++
#
#         {{ posttags }}
#
#         ## $title
#
#         \\toc
#
#         ### Subtitle
#         """)
#     end
# end
