window.board = {
  models: {},
  collections: {},
  views: {}
  instances: {}
}

# Base Classes

class board.views.baseSheet extends Backbone.View
  initialize: ->
    @collection.bind('reset', @render, this)

  render: ->
    @$el.empty()
    if @collection.length == 0
      @$el.html('Uh oh, something seems to have gone haywire with this feed. I\'ll try again in 10 minutes.')
    else
      @collection.each(@renderOne)

class board.views.base extends Backbone.View
  render: ->
    model = @model.toJSON()
    template = @template()
    @$el.append template(model)
    return this

# Tweets

class board.collections.tweets extends Backbone.Collection
  url: '/tweets'

class board.views.tweetSheet extends board.views.baseSheet
  el: '.twitter-section .tweets'

  renderOne: (item) =>
    view = new board.views.tweet(model: item)
    @$el.append view.render().el

class board.views.tweet extends board.views.base
  className: 'clearfix tweet'
  template: ->
    Handlebars.compile $('#tweetTemplate').html()

# Blogs

class board.collections.blogs extends Backbone.Collection
  url: '/blogs'

class board.views.blogSheet extends board.views.baseSheet
  el: '.blog-section .tweets'

  renderOne: (item) =>
    view = new board.views.blog(model: item)
    @$el.append view.render().el

class board.views.blog extends board.views.base
  className: 'clearfix tweet'
  template: ->
    Handlebars.compile $('#blogTemplate').html()

# Commits

class board.collections.commits extends Backbone.Collection
  url: '/commits'

class board.views.commitSheet extends board.views.baseSheet
  el: '.github-section .commits'

  renderOne: (item) =>
    view = new board.views.commit(model: item)
    @$el.append view.render().el

class board.views.commit extends board.views.base
  className: 'event clearfix git-item'
  template: ->
    Handlebars.compile $('#commitTemplate').html()

# Initialization

window.reloader = ->
  board.instances.commitCollection.fetch()
  board.instances.blogCollection.fetch()
  board.instances.tweetCollection.fetch()

  setTimeout "window.reloader()", ((1000 * 60) * 10)

$ ->
  board.instances.commitCollection = new board.collections.commits
  board.instances.commitSheet = new board.views.commitSheet(collection: board.instances.commitCollection)

  board.instances.blogCollection = new board.collections.blogs
  board.instances.blogSheet = new board.views.blogSheet(collection: board.instances.blogCollection)

  board.instances.tweetCollection = new board.collections.tweets
  board.instances.tweetSheet = new board.views.tweetSheet(collection: board.instances.tweetCollection)

  window.reloader()
