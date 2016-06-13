[ID, AILEVEL, FIRST_SHOT]  = [0, 1, true]

class Awale
  constructor: ->
    [@id, @player, @adversaire, @pointeur, @graphique, ] = [ID++, 0, 1, 1, 1]
    [@trous, @camp, @score] = [{}, {0: [1..6], 1: [7..12]}, {0: 0, 1: 0}]
    @trous[i] = 0 for i in [1..12]
    
    @depose_une_graine = ->
      @trous[@pointeur] += 1
      if @graphique
        r = (min, max) -> return (min + Math.floor(Math.random() * (max+1-min)))
        $( "#awale_#{@id} ##{@pointeur}" ).append "<div class='graine' style='transform: rotate(#{r(0,360)}deg); top: #{r(15,55)}%; left: #{r(15,55)}%;'></div>"

    @initialiser = ->    
      for i in [1..12]
        $( "#awale_#{@id} #camp#{if i<7 then 0 else 1}" ).append("<div id='#{@pointeur = i}' class='trou'>") if @graphique
        @depose_une_graine() for [1..4]
        
    @joueur_suivant = ->
      [@player, @adversaire] = [@adversaire, @player]
      $( "#awale_#{@id} .camp" ).toggleClass( "selected" ) if @graphique

    @trou_suivant   = -> @pointeur = @pointeur%12 + 1
    
    @trou_precedent = -> @pointeur = if @pointeur is 1 then 12 else @pointeur-1

    @total_graines = (joueur) -> 
      g = 0
      g += @trous[i] for i in @camp[joueur]
      return g

    @prendre_les_graines = ->
      [en_main, @trous[@pointeur] ] = [@trous[@pointeur], 0]
      $("#awale_#{@id} ##{@pointeur}").empty() if @graphique
      return en_main

    @prenable = ->
      [gain, grenier] = [0, @pointeur]
      while ( @trous[@pointeur] in [2,3] and @pointeur in @camp[@adversaire] )
        gain += @trous[@pointeur]
        @trou_precedent()
      @pointeur = grenier
      return ( (gain > 0) and (gain isnt @total_graines(@adversaire)) )

    @prendre = ->
      while ( (@trous[@pointeur] in [2,3]) and (@pointeur in @camp[@adversaire]) )
        @score[@player] += @prendre_les_graines()
        @trou_precedent()
      $( "#awale_#{@id} #score#{@player}" ).html(@score[@player]) if @graphique

    @reprendre_ses_graines = ->
      for player in [0,1]
        for trou in @camp[player]
          @score[player] += @trous[@pointeur = trou]
          @prendre_les_graines()
        $( "#score#{player}" ).html(@score[player]) if @graphique

    @fin_de_jeu = ->
      [gp, ga] = [@total_graines(@player), @total_graines(@adversaire)]
      [t1,t2, t7, t8] = [@trous[1], @trous[2], @trous[7], @trous[8]]
      config1 = ( gp is ga is t1 is t7 is 1 )
      config2 = ( gp is ga is 2) and (t1 is t2 is t7 is t8 is 1)
      if config1 or config2 then return true
      else (if @jouable(trou) then return false) for trou in @camp[@player]        
      return true
    
    @nourrirAdversaire = -> return (@pointeur + @trous[@pointeur]) > (6*@player+6)
    
    @jouable = (@pointeur) ->
      if ( (@pointeur in @camp[@player]) and (@trous[@pointeur]>0) )
        if @total_graines(@adversaire) is 0 then return (@nourrirAdversaire())
        else return true
      else return false
      
    @jouer = (@pointeur) ->
      grenier = @pointeur
      en_main = @prendre_les_graines() 
      while en_main > 0
        @trou_suivant()
        if @pointeur isnt grenier 
          @depose_une_graine()
          en_main -= 1
      @prendre() if @prenable()    
      @joueur_suivant()       
      if @fin_de_jeu()  
        alert "jeu terminé !" if @graphique
        @reprendre_ses_graines()        
    
    @essayer = (@pointeur) ->
      if @jouable(@pointeur) then @jouer(@pointeur)
      else $( "##{@pointeur}" ).append $( "#info" ).html(":(").show()

$ ->
  awale = new Awale()
  awale.initialiser()
  
  on_first_shot = (trou) ->
    trou ?= Math.floor(Math.random() * 12) + 1
    [awale.player, awale.adversaire] = if trou in [1..6] then [0, 1] else [1, 0]
    $( "#awale_#{awale.id} #camp#{awale.player}" ).addClass( "selected" )
    FIRST_SHOT = false
  
  $( ".trou" ).on "click", ->
    switch $( this ).hasClass "selected"
      when true
        $( this ).removeClass "selected" 
        $( "#awale_#{awale.id}" ).append $( "#info" ).hide()
        t = parseInt( $( this ).attr "id" )
        on_first_shot(t) if FIRST_SHOT
        awale.essayer(t)
      else
        t = parseInt( $( this ).attr "id" )
        $( ".trou" ).removeClass( "selected" )
        $( this ).addClass( "selected" ).append( $( "#info" ).html(awale.trous[t]).show() )    
    
  $("input[name=AIlevel]").on "click", -> AILEVEL = parseInt($(this).val())
  
  $( "#ordi" ).on "click", ->
    $( "#awale_#{awale.id}" ).append $( "#info" ).hide()
    on_first_shot() if FIRST_SHOT
    [ai, adversaire, level, max, best_shot] = [awale.player, awale.adversaire, 0, -49, 0]
    for best_shot in awale.camp[awale.player]
      break if awale.jouable(best_shot)     

    clone = (obj) ->
      return obj if not obj? or typeof obj isnt 'object'
      newInstance = new obj.constructor()
      newInstance[key] = clone obj[key] for key of obj
      return newInstance

    virtual_shot = (awales) ->
      new_awales = {}
      for key, game of awales
        for trou in game.camp[game.player]        
          if game.jouable(trou)
            new_awales[index = "#{key}#{trou}."] = clone game
            new_awales[index].graphique = false
            new_awales[index].jouer(trou)
            [sj, sa] = [new_awales[index].score[ai], new_awales[index].score[adversaire]]       
            if ( (delta = sj-sa) > max)
              [max, best_shot] = [delta, parseInt(index[0..1])]
              console.log "Level #{level}:#{sj}-#{sa} -> #{best_shot} [#{index}]"
      virtual_shot(new_awales, level) if (level++ < AILEVEL)

    virtual_shot({"" : awale})
    $( "#infoAI" ).html "Je vais jouer le trou #{best_shot}"
    awale.jouer(best_shot)

