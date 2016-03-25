unique_id = 0
debug = false
$graines = 4

clone = (obj) ->
  return obj if not obj? or typeof obj isnt 'object'
  newInstance = new obj.constructor()
  newInstance[key] = clone obj[key] for key of obj
  return newInstance
  
class Awale
  constructor: ->
    [@id, @player, @adversaire, @pointeur, @graphique, @trous] = [unique_id++, 0, 1, 1, 1, {} ]
    @trous[i] = 0 for i in [1..12]     
    @camps = {0: [1..6], 1: [7..12]}
    @score = {0: 0, 1: 0}

    @initialiser = () ->
      for i in [1..12]
        @pointeur = i
        @depose_une_graine() for j in [1..$graines]
          
    @joueur_suivant = ->
      [@player, @adversaire] = [@adversaire, @player]
      $( "#awalé_#{@id} .camp" ).toggleClass( "selected" ) if @graphique

    @trou_suivant   = -> @pointeur = @pointeur%12 + 1
    @trou_precedent = -> @pointeur = (@pointeur - 1)%12

    @total_graines = (joueur, g = 0) -> 
      g += @trous[i] for i in @camps[joueur]
      return g

    @prendre_les_graines = ->
      console.log "$ @prendre_les_graines : en ce moment il y a #{@trous[@pointeur]} graine(s) dans le trou #{@pointeur}" if debug
      [main, @trous[@pointeur] ] = [@trous[@pointeur], 0]
      $("##{@pointeur}").empty() if @graphique
      return main
      
    @depose_une_graine = ->
      @trous[@pointeur] += 1
      if @graphique
        $( "##{@pointeur}" ).append( "<div class='graine'></div>" )
        $( "##{@pointeur} .graine" ).each ->
          rand = -> return (10 + Math.floor(Math.random() * 45))
          $( this ).css {top : "#{rand()}%", left: "#{rand()}%", transform: "rotate(#{3*rand()}deg)"}

    @nourrirAdversaire = -> return (@pointeur + @trous[@pointeur] > 6*(@player+1))

    @prenable = (origine = @pointeur, gain_virtuel = 0) ->
      while ( (@trous[@pointeur] in [2,3]) and (@pointeur in @camps[@adversaire]) )
        gain_virtuel += @trous[@pointeur]
        @trou_precedent()
      @pointeur = origine
      return ( (gain_virtuel > 0) and (gain_virtuel isnt @total_graines(@adversaire)) )

    @prendre = () ->
      console.log "$ @prendre() : il y a prise !" if debug
      while ( (@trous[@pointeur] in [2,3]) and (@pointeur in @camps[@adversaire]) )
        @score[@player] += @trous[@pointeur]
        @prendre_les_graines()
        $( "#score#{@player}" ).html(@score[@player]) if @graphique
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
        #console.log "le pointeur(#{@pointeur}) pointe sur une case du joueur#{@player}: #{@pointeur in @camps[@player]}" if debug
        switch @total_graines(@adversaire) 
          when 0
            console.log @nourrirAdversaire()
            return (@nourrirAdversaire())
          else return true
      else
        #console.log "le pointeur(#{@pointeur}) ne pointe pas sur une case du joueur #{@player}: #{@pointeur in @camps[@player]}" if debug
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
      console.log "argh, ce n'est pas jouable !"    

  to_html : -> 
    $awalé = $( "<div><div id='awalé_#{@id}' class='awalé'><div id='camp0' class='camp'></div><div id='camp1' class='camp'></div></div></div>" )
    for trou in [1..12]
      $awalé.find( "#camp#{if trou<7 then 0 else 1}" ).append "<div id='#{trou}' class='trou'>"
      @pointeur = trou
      @depose_une_graine() for j in [0..@trous[j]-1]
    return $awalé.html()     

$ ->
  awale = new Awale()
  $( "#game" ).append awale.to_html()
  awale.initialiser()

  first_dblclick = true
  
  $( ".trou" ).on "click", ->
    t = parseInt( $( this ).attr "id" )
    $( ".trou" ).removeClass "selected"
    $( this ).addClass "selected"
    $( this ).append $( "#info" ).html(awale.trous[t]).show()   

  $( ".trou" ).on "dblclick", ->
    t = parseInt( $( this ).attr "id" )
    if first_dblclick
      [awale.player, awale.adversaire] = if t in [1..6] then [0, 1] else [1, 0]
      $( "#awalé_#{awale.id} #camp#{awale.player}" ).addClass( "selected" )
      first_dblclick = false
    $( "body" ).append $( "#info" ).hide()
    awale.jouer(t)

  aiLevel = 1
  $("input[name=AIlevel]").on "click", -> aiLevel = parseInt($(this).val())
  
  $( "#ordi" ).on "click", ->
    if first_dblclick
      t = Math.floor(Math.random() * 2)
      [awale.player, awale.adversaire] = if t in [1..6] then [0, 1] else [1, 0]
      $( "#awalé_#{awale.id} #camp#{awale.player}" ).addClass( "selected" )
      first_dblclick = false
    max = -50
    best = -1
    for i in awale.camps[awale.player]
      if awale.jouable(i)
        best = i
        break
    alert "???" if best is -1
        
    level = 0
    virtual_shot = (awales, ai, adversaire) ->
      new_awales = {}
      for key, game of awales
        for i in game.camps[game.player]  
          if game.jouable(i)
            index = "#{key}##{i}."
            #console.log "index #{index}"
            new_awales[index] = clone game
            new_awales[index].graphique = false
            new_awales[index].jouer(i) 
            
            delta = new_awales[index].score[ai]-new_awales[index].score[adversaire]
            if (delta>max)
              [max, best] = [delta, parseInt(index[2..3])]
              console.log "au niveau #{level} je change de strategie, je vise #{new_awales[index].score[ai]}-#{new_awales[index].score[adversaire]} en jouant le trou #{best}"
      return new_awales    

    a = {"#" : awale }
    
    while level++ < aiLevel
      console.log "level #{level}"
      a = virtual_shot(a, awale.player, awale.adversaire)
           
    console.log "Je vais t'éclater en jouant le trou #{best}"
    awale.jouer(best)
    
          
        
    
      
       
