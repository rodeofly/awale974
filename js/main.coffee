[ID, AILEVEL, GRAINES, DEBUG]  = [0, 1, 4, false]
  
class Awale
  constructor: ->
    [@id, @player, @adversaire, @pointeur, @graphique, ] = [ID++, 0, 1, 1, 1]
    [@trous, @camps, @score] = [{}, {0: [1..6], 1: [7..12]}, {0: 0, 1: 0}]
    @trous[i] = 0 for i in [1..12]
        
    @initialiser = ->
      for i in [1..12]
        @pointeur = i
        @depose_une_graine() for [1..GRAINES]
          
    @joueur_suivant = ->
      [@player, @adversaire] = [@adversaire, @player]
      $( "#awalé_#{@id} .camp" ).toggleClass( "selected" ) if @graphique

    @trou_suivant   = -> @pointeur = @pointeur%12 + 1
    
    @trou_precedent = -> @pointeur = if @pointeur is 1 then 12 else @pointeur-1

    @total_graines = (joueur) -> 
      g = 0
      g += @trous[i] for i in @camps[joueur]
      return g

    @prendre_les_graines = ->
      console.log "[#{@trous[@pointeur]} graine(s)] en #{@pointeur}" if DEBUG
      [main, @trous[@pointeur] ] = [@trous[@pointeur], 0]
      $("#awalé_#{@id} ##{@pointeur}").empty() if @graphique
      return main
      
    @depose_une_graine = ->
      @trous[@pointeur] += 1
      if @graphique
        $( "#awalé_#{@id} ##{@pointeur}" ).append "<div class='graine'></div>"
        $( "#awalé_#{@id} ##{@pointeur} .graine" ).each ->
          rand = -> return (15 + Math.floor(Math.random() * 35))
          $( this )
            .css(transform: "rotate(#{10*rand()}deg)")
            .animate {top : "#{rand()}%", left: "#{rand()}%"}

    # @prenable() return boolean : on verifie que l'on affame pas l'adversaire
    @prenable = (origine = @pointeur) ->
      gain = 0
      while ( @trous[@pointeur] in [2,3] and @pointeur in @camps[@adversaire] )
        gain += @trous[@pointeur]
        @trou_precedent()
      @pointeur = origine
      return ( (gain > 0) and (gain isnt @total_graines(@adversaire)) )

    @prendre = () ->
      while ( (@trous[@pointeur] in [2,3]) and (@pointeur in @camps[@adversaire]) )
        main = @prendre_les_graines()
        @score[@player] += main
        @trou_precedent()
      $( "#awalé_#{@id} #score#{@player}" ).html(@score[@player]) if @graphique
    #Quand la partie est finie, chaque joueur gagne les graines de son camp
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
    
    @nourrirAdversaire = -> return @pointeur + @trous[@pointeur] > 6*@player+6
    
    @jouable = (@pointeur) ->
      console.log "$ @jouable(#{@pointeur}) : Ce coup est-il jouable ?" if DEBUG  
      if ( (@pointeur in @camps[@player]) and (@trous[@pointeur]>0) )
        if @total_graines(@adversaire) is 0 then return (@nourrirAdversaire())
        else return true
      else return false
      
  jouer : (@pointeur) ->
    console.log "J#{@player} -> #{@pointeur}[#{@trous[@pointeur]}gr]" if DEBUG
    if @jouable(@pointeur)
      origine = @pointeur
      main = @prendre_les_graines() 
      while main-- > 0
        @trou_suivant()
        if @pointeur isnt origine then @depose_une_graine()
      @prendre() if @prenable()    
      @joueur_suivant()       
      if @fin_de_jeu()  
        alert "jeu terminé !" if @graphique
        @reprendre_ses_graines()
    else $( "##{@pointeur}" ).append $( "#info" ).html(":(").show()

  to_html : ->
    html = """
    <div><div id='awalé_#{@id}' class='awalé'>
        <div id='info'   class='score'></div>
        <div id='score0' class='score'></div><div id='score1' class='score'></div>
        <div id='camp0' class='camp'></div><div id='camp1' class='camp'></div>
    </div></div>"""
    $awalé = $( html )
    for trou in [1..12]
      $awalé.find( "#camp#{if trou<7 then 0 else 1}" ).append "<div id='#{trou}' class='trou'>"
      @pointeur = trou
      main = @trous[trou]
      @depose_une_graine() while main--
    return $awalé.html()     

$ ->
  awale = new Awale()
  $( "#game" ).append awale.to_html()
  awale.initialiser()
  first_shot = true
  
  $( ".trou" ).on "click", ->
    t = parseInt( $( this ).attr "id" )
    $( ".trou" ).removeClass( "selected" )
    $( this ).addClass( "selected" ).append( $( "#info" ).html(awale.trous[t]).show() ) 
  
  on_first_shot = (trou) ->
    trou ?= Math.floor(Math.random() * 12) + 1
    [awale.player, awale.adversaire] = if trou in [1..6] then [0, 1] else [1, 0]
    $( "#awalé_#{awale.id} #camp#{awale.player}" ).addClass( "selected" )
    first_shot = false
    
  $( ".trou" ).on "dblclick", ->
    t = parseInt( $( this ).attr "id" )
    on_first_shot(t) if first_shot
    $( "#awalé_#{awale.id}" ).append $( "#info" ).hide()
    awale.jouer(t)
  # IAG : Intelligence Artificielle Gatée
  $("input[name=AIlevel]").on "click", -> AILEVEL = parseInt($(this).val())
  
  $( "#ordi" ).on "click", ->
    on_first_shot() if first_shot    
    $( "#awalé_#{awale.id}" ).append $( "#info" ).hide()
    [level, max, best] = [0, -50,-1]
    for best in awale.camps[awale.player]
      break if awale.jouable(best)     

    virtual_shot = (awales, ai, adversaire) ->
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
    while level++ < AILEVEL
      console.log "niveau #{level}" if DEBUG
      a = virtual_shot(a, awale.player, awale.adversaire)         
    console.log "Je vais t'éclater en jouant le trou #{best}"
    awale.jouer(best)
    
