[ID, AILEVEL]  = [0, 1]

class Awale
  constructor: ->
    [@id, @player, @adversaire, @pointeur, @graphique, ] = [ID++, 0, 1, 1, 1]
    [@trous, @camps, @score] = [{}, {0: [1..6], 1: [7..12]}, {0: 0, 1: 0}]
    @trous[i] = 0 for i in [1..12]
    
    @depose_une_graine = ->
      @trous[@pointeur] += 1
      if @graphique
        $( "#awale_#{@id} ##{@pointeur}" ).append "<div class='graine'></div>"
        rand = -> return (15 + Math.floor(Math.random() * 35))
        $( "#awale_#{@id} ##{@pointeur} .graine" ).last().css { transform : "rotate(#{99*rand()}deg)", top: "#{rand()}%", left: "#{rand()}%"}

    @initialiser = ->    
      for i in [1..12]
        if @graphique
          $( "#awale_#{@id} #camp#{if i<7 then 0 else 1}" ).append "<div id='#{i}' class='trou'>"
        @pointeur = i
        @depose_une_graine() for [1..4]
        
    @joueur_suivant = ->
      [@player, @adversaire] = [@adversaire, @player]
      $( "#awale_#{@id} .camp" ).toggleClass( "selected" ) if @graphique

    @trou_suivant   = -> @pointeur = @pointeur%12 + 1
    
    @trou_precedent = -> @pointeur = if @pointeur is 1 then 12 else @pointeur-1

    @total_graines = (joueur) -> 
      g = 0
      g += @trous[i] for i in @camps[joueur]
      return g

    @prendre_les_graines = ->
      [main, @trous[@pointeur] ] = [@trous[@pointeur], 0]
      $("#awale_#{@id} ##{@pointeur}").empty() if @graphique
      return main

    @prenable = ->
      [gain, origine] = [0, @pointeur]
      while ( @trous[@pointeur] in [2,3] and @pointeur in @camps[@adversaire] )
        gain += @trous[@pointeur]
        @trou_precedent()
      @pointeur = origine
      return ( (gain > 0) and (gain isnt @total_graines(@adversaire)) )

    @prendre = ->
      while ( (@trous[@pointeur] in [2,3]) and (@pointeur in @camps[@adversaire]) )
        main = @prendre_les_graines()
        @score[@player] += main
        @trou_precedent()
      $( "#awale_#{@id} #score#{@player}" ).html(@score[@player]) if @graphique

    @reprendre_ses_graines = ->
      for player in [0,1]
        for trou in @camps[player]
          @pointeur = trou
          @score[player] += @trous[@pointeur]
          @prendre_les_graines()
        $( "#score#{player}" ).html(@score[player]) if @graphique

    @fin_de_jeu = ->
      the_end = true
      [gp, ga] = [@total_graines(@player), @total_graines(@adversaire)]
      [t1,t2, t7, t8] = [@trous[1], @trous[2], @trous[7], @trous[8]]
      config1 = ( gp is ga is t1 is t7 is 1 )
      config2 = ( gp is ga is 2) and (t1 is t2 is t7 is t8 is 1)
      if config1 or config2 then return the_end
      else
        for trou in @camps[@player]
          the_end = (not the_end) if @jouable(trou)
          break if (not the_end)
      return the_end
    
    @nourrirAdversaire = -> return (@pointeur + @trous[@pointeur]) > (6*@player+6)
    
    @jouable = (@pointeur) ->
      if ( (@pointeur in @camps[@player]) and (@trous[@pointeur]>0) )
        if @total_graines(@adversaire) is 0 then return (@nourrirAdversaire())
        else return true
      else return false
      
    @jouer = (@pointeur) ->
        origine = @pointeur
        main = @prendre_les_graines() 
        while main > 0
          @trou_suivant()
          if @pointeur isnt origine 
            @depose_une_graine()
            main -= 1
        @prendre() if @prenable()    
        @joueur_suivant()       
        if @fin_de_jeu()  
          alert "jeu terminé !" if @graphique
          @reprendre_ses_graines()        
    
    @essayer = (@pointeur) ->
      if @jouable(@pointeur) then @jouer(@pointeur)
      else
        $( "##{@pointeur}" ).append $( "#info" ).html(":(").show() if @graphique

$ ->
  awale = new Awale()
  awale.initialiser()
  
  $( ".trou" ).on "click", ->
    t = parseInt( $( this ).attr "id" )
    $( ".trou" ).removeClass( "selected" )
    $( this ).addClass( "selected" ).append( $( "#info" ).html(awale.trous[t]).show() ) 
  
  first_shot = true
  on_first_shot = (trou) ->
    trou ?= Math.floor(Math.random() * 12) + 1
    [awale.player, awale.adversaire] = if trou in [1..6] then [0, 1] else [1, 0]
    $( "#awale_#{awale.id} #camp#{awale.player}" ).addClass( "selected" )
    first_shot = false
    
  $( ".trou" ).on "dblclick", ->
    $( "#awale_#{awale.id}" ).append $( "#info" ).hide()
    t = parseInt( $( this ).attr "id" )
    on_first_shot(t) if first_shot
    awale.essayer(t)
    
  $("input[name=AIlevel]").on "click", -> AILEVEL = parseInt($(this).val())
  
  $( "#ordi" ).on "click", ->
    $( "#awale_#{awale.id}" ).append $( "#info" ).hide()
    on_first_shot() if first_shot
    [ai, adversaire, level, max, best] = [awale.player, awale.adversaire, 0, -49, 0]
    for best in awale.camps[awale.player]
      break if awale.jouable(best)     

    virtual_shot = (awales) ->
      clone = (obj) ->
        return obj if not obj? or typeof obj isnt 'object'
        newInstance = new obj.constructor()
        newInstance[key] = clone obj[key] for key of obj
        return newInstance
      new_awales = {}
      for key, game of awales
        for i in game.camps[game.player]  
          if game.jouable(i)
            index = "#{key}#{i}."
            new_awales[index] = clone game
            new_awales[index].graphique = false
            new_awales[index].jouer(i)
            [sj, sa] = [new_awales[index].score[ai], new_awales[index].score[adversaire]]       
            if ( (delta = sj-sa) > max)
              [max, best] = [delta, parseInt(index[0..1])]
              console.log "L#{level}:#{sj}-#{sa} -> #{best} [#{index}]"
      return new_awales
    
    a = {"" : awale } 
    a = virtual_shot(a) while level++ < AILEVEL          
    console.log "Je vais t'éclater en jouant le trou #{best}"
    awale.jouer(best)
    
