require 'idea_box'

class IdeaBoxApp < Sinatra::Base

  set :method_override, true
  set :root, 'lib/app'

  register Sinatra::AssetPack

  assets {
    serve '/js',     from: 'js'        # Default
    serve '/css',    from: 'css'       # Default
    serve '/images', from: 'images'    # Default

    # The second parameter defines where the compressed version will be served.
    # (Note: that parameter is optional, AssetPack will figure it out.)
    # The final parameter is an array of glob patterns defining the contents
    # of the package (as matched on the public URIs, not the filesystem)
    # js :app, '/js/bootstrap.js', [
    #   '/js/bootstrap.js'
    # ]

    css :application, '/css/bootstrap.css', [
       '/css/bootstrap.min.css'
    ]

    # js_compression  :jsmin    # :jsmin | :yui | :closure | :uglify
    css_compression :simple   # :simple | :sass | :yui | :sqwish
  }

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    if params[:tag_sort]
      ideas = IdeaStore.view_by_tag(params[:tag_sort])
    else
      ideas = IdeaStore.all.sort
    end
    erb :index, locals: {
        ideas: ideas,
        idea: Idea.new,
        tags: IdeaStore.all_tags
      }
  end

  post '/' do
    IdeaStore.create(params[:idea])
    redirect '/'
  end

  get '/by_tags' do
    erb :by_tags, locals: {ideas: IdeaStore.all}
  end

  delete '/:id' do |id|
    IdeaStore.delete(id.to_i)
    redirect '/'
  end

  get '/:id/edit' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :edit, locals: {idea: idea}
  end

  put '/:id' do |id|
    IdeaStore.update(id.to_i, params["idea"])
    redirect '/'
  end

  post '/:id/like' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.like!
    IdeaStore.update(id.to_i, idea.to_h)
    redirect '/'
  end

  not_found do
    erb :error
  end

end
