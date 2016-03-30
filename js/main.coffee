unique_id = 0
debug = false
$graines = 4
  
class Awale
  constructor: ->
    [@id, @player, @adversaire, @pointeur, @graphique, ] = [unique_id++, 0, 1, 1, 1]
    [@trous, @camps, @score] = [{}, {0: [1..6], 1: [7..12]}, {0: 0, 1: 0}]
    @trous[i] = 0 for i in [1..12]
        
    @initialiser = ->
      for i in [1..12]
        @pointeur = i
        @depose_une_graine() for [1..$graines]
          
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
      console.log "$ @prendre_les_graines : en ce moment il y a #{@trous[@pointeur]} graine(s) dans le trou #{@pointeur}" if debug
      [main, @trous[@pointeur] ] = [@trous[@pointeur], 0]
      $("#awalé_#{@id} ##{@pointeur}").empty() if @graphique
      return main
      
    @depose_une_graine = ->
      @trous[@pointeur] += 1
      if @graphique
        $( "#awalé_#{@id} ##{@pointeur}" ).append( "<div class='graine'></div>" )
        $( "#awalé_#{@id} ##{@pointeur} .graine" ).each ->
          rand = -> return (15 + Math.floor(Math.random() * 35))
          $( this ).css(transform: "rotate(#{3*rand()}deg)").animate {top : "#{rand()}%", left: "#{rand()}%"}

    @nourrirAdversaire = -> return (@pointeur + @trous[@pointeur] > 6*(@player+1))

    @prenable = (origine = @pointeur) ->
      gain = 0
      while ( (@trous[@pointeur] in [2,3]) and (@pointeur in @camps[@adversaire]) )
        gain += @trous[@pointeur]
        @trou_precedent()
      @pointeur = origine
      return ( (gain > 0) and (gain isnt @total_graines(@adversaire)) )

    @prendre = () ->
      while ( (@trous[@pointeur] in [2,3]) and (@pointeur in @camps[@adversaire]) )
        @score[@player] += @trous[@pointeur]
        @prendre_les_graines()
        $( "#awalé_#{@id} #score#{@player}" ).html(@score[@player]) if @graphique
        @trou_precedent()

    @reprendre_ses_graines = ->
      for player in [0,1]
        for trou in @camps[player]
          @pointeur = trou
          @score[player] += @trous[@pointeur]
          @prendre_les_graines()
        $( "#score#{player}" ).html(@score[player]) if @graphique

    @fin_de_jeu = ->
      the_end = true
      config1 = ( (@total_graines(@player) is 1) and (@total_graines(@adversaire) is 1) and ((@trous[1] is 1) and (@trous[7] is 1) ) )
      config2 = ( (@total_graines(@player) is 2) and (@total_graines(@adversaire) is 2) and ((@trous[1] is 1) and (@trous[2] is 1) and (@trous[7] is 1) and (@trous[8] is 1) ) )
      if config1 or config2
        return the_end
      else
        for trou in @camps[@player]
          the_end = (not the_end) if @jouable(trou)
          break if (not the_end)
      return the_end

    @jouable = (@pointeur) ->
      console.log "$ @jouable(#{@pointeur}) : Ce coup est-il jouable ?" if debug 
      if ( (@pointeur in @camps[@player]) and (@trous[@pointeur]>0) )
        if @total_graines(@adversaire) is 0
          return (@nourrirAdversaire())
        else return true
      else
        return false
      
  jouer : (@pointeur) ->
    console.log "joueur#{@player} veut jouer le trou #{@pointeur} dans lequel il y a #{@trous[@pointeur]} graine(s)" if debug
    if @jouable(@pointeur)
      origine = @pointeur
      main = @prendre_les_graines() 
      console.log "ok, c'est jouable ! le pointeur est en #{@pointeur}, je prend #{main} graine(s) dans ma main." if debug
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
    else
      console.log "argh, ce n'est pas jouable !" if debug  

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
      @depose_une_graine() for [1..@trous[trou]]
    return $awalé.html()     

$ ->
  awale = new Awale()
  $( "#game" ).append awale.to_html()
  awale.initialiser()
  [aiLevel, first_shot] = [1, true]
  
  $("input[name=AIlevel]").on "click", -> aiLevel = parseInt($(this).val())
  
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
    $( "#game" ).append $( "#info" ).hide()
    awale.jouer(t)
  
  $( "#ordi" ).on "click", ->
    on_first_shot() if first_shot    
    [level, max, best] = [0, -50,-1]
    for i in awale.camps[awale.player]
      if awale.jouable(i)
        best = i
        break      

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
            index = "#{key}##{i}."
            new_awales[index] = clone game
            new_awales[index].graphique = false
            new_awales[index].jouer(i)   
            delta = new_awales[index].score[ai]-new_awales[index].score[adversaire]
            if (delta>max)
              [max, best] = [delta, parseInt(index[2..3])]
              console.log "au niveau #{level}, je vise #{new_awales[index].score[ai]}-#{new_awales[index].score[adversaire]} en jouant le trou #{best}"
      return new_awales    
    
    a = {"#" : awale } 
    while level++ < aiLevel
      console.log "niveau #{level}"
      a = virtual_shot(a, awale.player, awale.adversaire)         
    console.log "Je vais t'éclater en jouant le trou #{best}"
    awale.jouer(best)
    
