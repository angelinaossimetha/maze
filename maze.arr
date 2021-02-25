#Angelina and Rachael
# Project 2 Submission
# load the project support code
include shared-gdrive(
  "project-2-support.arr",
  "1J04p2lnp_FYTXWQbYUfcYQtddjHqUgJs")  
include shared-gdrive("cs111-2018.arr", 
  "1XxbD-eg5BAYuufv6mLmEllyg28IR7HeX")
include image
include tables
include reactors
import lists as L   

#######################
## Image Definitions ##
#######################

#images
WALL = load-texture("tex-5.png")
GROUND = load-texture("tex-7.png") 
APPLE = load-texture("apple.png") 
TOMATO = load-texture("tomato.png")  
BANANA = load-texture("banana.png")   

DOWN = load-texture("char-2-down.png")
UP = load-texture("char-2-up.png")
LEFT = load-texture("char-2-left.png")
RIGHT = load-texture("char-2-right.png") 

#food affects
TOMATO-AFFECT = -7 
BANANA-AFFECT = 20 


##### Initial Stamina #####
INITIAL-STAMINA = 100   

##### Key-Pressed List #####
KEYS = [list: "w", "a", "s", "d"]

####################
### Support Code ###
####################

ssid = "1oHQsZ07PilWKNGzMC9xqB2beF9YNVT6AwWyM23nNTRQ"
maze-data = load-maze(ssid)
item-data = load-items(ssid) 

###############################
######### Data Types ##########
###############################

##########
## Posn ##
##########

data Posn:
  | posn(x :: Number, y :: Number)
end 

#Examples
posn1 = posn(3,2) 
posn2 = posn(18,2)
posn3 = posn(20,11)  

##########
## Item ##
##########

data Item:  
  |apple(position :: Posn, img :: Image)  
  |tomato(position :: Posn,img :: Image)  
  |banana(position :: Posn, img :: Image) 
end 

#Examples 
apples = apple(posn(8,2),APPLE)
tomatos = tomato(posn(4,2),TOMATO) 
bananas = banana(posn(5,3),BANANA)

######################
## Test Definitions ##
######################

test-table = table: name, x, y, url
  row: "Apple",22,	2	,APPLE
  row: "Tomato",	4	,2,	TOMATO
  row: "Banana", 5,	3	,BANANA
    #row:"Portal"	,29	,4	,"portal.png"
end  

test-table-results = [list: apple(posn(22,2),APPLE),
  tomato(posn(4,2),TOMATO),banana(posn(5,3),BANANA)]  

##########################################
## Helper Function: Table to List Items ##
##########################################

fun table-to-list-items(t :: Table) -> List<Item>:  
  doc:```Takes in a Table with a column called "name"
         (with Strings ONLY: "Apple","Tomato", or "Portal"), 
          "x", and "y". Returns a List<Item> which is a imputed
          table converted to a List<Item> .```

  table-temp-list = t.all-rows() 

  fun make-list-items(lst :: List<Row>) -> List<Item>: 
    doc:```Takes a List<Row> as input and extracts the columns
           "name", "x-value", and "y-value"(must have these columns)
           in a row. Outputs a List<Item>, with x and y-values
           as Posns.```

    cases(List) lst:  
      |empty => empty
      |link(fst,rst) => if string-equal(fst.get-value("name"),"Apple"):      
          link(apple(posn(fst.get-value("x"), 
                fst.get-value("y")),APPLE) , make-list-items(rst)) 
        else if string-equal(fst.get-value("name"),"Tomato"): 
          link(tomato(posn(fst.get-value("x"), 
                fst.get-value("y")),TOMATO),make-list-items(rst))
        else: 
          link(banana(posn(fst.get-value("x"), 
                fst.get-value("y")),BANANA),make-list-items(rst))
        end 
    end   
  end 

  make-list-items(table-temp-list)  

where:  
  table-to-list-items(test-table) is test-table-results  #general case                       
  table-to-list-items(test-table.empty()) is empty #empty case 
end 

###############################
######### Data Types ##########
###############################

###############
## Character ##
###############

data Character: 
  |character(position :: Posn, direction:: String)
end  

#Examples
character1 = character(posn(3,2), "w") 
character2 = character(posn(18,2), "d") 
character3 = character(posn(20,11), "a")  

###############
## GameState ##
###############

data GameState: 
  |state(char :: Character, stamina :: Number, 
      items :: List<Item>)   
end    

#Examples
game-state1 = state(character(posn(3,2), "w"),100, 
  [list: apple(posn(8,2),APPLE), tomato(posn(4,2),TOMATO), 
    banana(posn(5,3), BANANA)]) 

game-state2 = state(character2, 50, [list: apples,tomatos,bananas])  

game-state3 = state(character(posn(20,11), "w"),0, 
  [list: apple(posn(13,6),APPLE), tomato(posn(4,2),TOMATO), 
    banana(posn(5,3), BANANA)]) 

########################
## Static Definitions ##
######################## 

##### Initial-Character #####
INITIAL-CHARACTER = character(posn(2,2),"d") 

##### Initial-Items ######
INITIAL-ITEMS = table-to-list-items(item-data)

##### Initial-State #####
INITIAL-STATE = state(INITIAL-CHARACTER, 
  INITIAL-STAMINA, INITIAL-ITEMS)

##################################
## Helper Function: Convert-X-Y ##
##################################

fun convert-x-y(pos :: Posn) -> Posn:   
  doc: ```Must take in a Posn with x and y values > 0,
          and converts Posn to pixel Posns; otherwise raises 
          message if <= 0.```
  if (pos.x > 0) and (pos.y > 0):
    x-pixels =   (30 * pos.x) - 15
    y-pixels =  (30 * pos.y) - 15
    posn(x-pixels, y-pixels)  
  else: 
    raise("Number NOT greater than 0.") 
  end 
where: 
  convert-x-y(posn(4,2)) is posn((30 * 4) - 15, (30 * 2) - 15) 
  #general case
  convert-x-y(posn(0,0)) raises "Number NOT greater than 0."
  #raise case 

end 

############################################
## Helper Function: Remove Item from List ##
############################################

######## Test Definitions #########

test-list = [list: apple(posn(22,2), APPLE), tomato(posn(4,2), TOMATO),
  banana(posn(5,3),BANANA)]   

test-list-results  = [list: apple(posn(22,2),APPLE), 
  banana(posn(5,3),BANANA)]

fun remove-item(lst :: List<Item>, pos :: Posn) -> List<Item>:  
  doc: ```Takes in a List<Item> and a Posn which represents 
          the characters new position.Returns a new List<Item> 
          with the item removed that has the same Posn as the 
          imputed Posn.```
  cases(List) lst:  
    |empty => empty
    |link(fst,rst) => if fst.position == pos:
        rst 
      else: 
        link(fst,remove-item(rst,pos))
      end
  end 
where:  
  remove-item(test-list, posn(4,2)) is test-list-results #general case
  remove-item(empty, posn(4,2)) is empty #empty case 
  remove-item(test-list, posn(13,6)) is test-list 
  #posn not in the list case 
end    


##############################################
## Helper Function: Update Character's Posn ##
##############################################

fun new-char-posn(press :: String, g-state :: GameState) -> Posn:   
  doc: ``` ONLY takes in a lower case "w", "a", "s", or "d"
           key and GameState (the character Posn in GameState
           should be > 0 both x and y positions and returns a
           Posn based on the keypress input.```
  posn-temp = g-state.char.position

  if string-equal(press,"w"): 
    posn(posn-temp.x, posn-temp.y - 1)
  else if string-equal(press,"s"): 
    posn(posn-temp.x, posn-temp.y + 1)
  else if string-equal(press,"d"): 
    posn(posn-temp.x + 1, posn-temp.y)
  else if string-equal(press,"a"):  
    posn(posn-temp.x - 1, posn-temp.y) 
  else:  
    posn-temp
  end  
where:  
  new-char-posn("w", game-state3) is posn(20, 11 - 1) #"w" case
  new-char-posn("s", game-state2) is posn(18, 2 + 1) #"s" case 
  new-char-posn("d",game-state1) is posn(3 + 1, 2) #"d" case 
  new-char-posn("a",game-state1) is posn(3 - 1, 2) #"a" case  
  new-char-posn("y",game-state2) is posn(18, 2) #else case  
end  

######################################
### Helper Function: Check if Wall ###
######################################

fun is-a-wall(lst :: List<List<String>>, p :: Posn) -> Boolean:
  doc: ```Takes in a list of a list of a strings that 
          represent wall tiles and ground tiles and the
          character's Posn. If the character tries to
          move into a wall, return true.``` 
  (lst.get(p.y - 1).get(p.x - 1) == "x")
where:
  is-a-wall([list:[list: "x", "o"], 
      [list: "x", "x", "x"]], posn(3,2)) is true
  # wall case
  is-a-wall([list:[list: "o", "x"], 
      [list: "o", "o", "o"]], posn(3,2)) is false
  # not a wall case
  is-a-wall([list: [list:], empty], posn(2,2)) raises "n too large"
  # error case
end 

########################
### Test Definitions ###
########################

orginal-game-state = state(character(posn(4,3), "d"), 
  100, table-to-list-items(item-data))

new-game-state = state(character(posn(4,3 - 1), "w"), 
  (100 - 1 ) + TOMATO-AFFECT,
  remove-item(INITIAL-ITEMS,posn(4,3 - 1)))  

orginal-game-state1 = state(character(posn(5,2), "d"), 
  100, INITIAL-ITEMS)

new-game-state1 = state(character(posn(5,2 + 1), "s"), 
  99,
  remove-item(INITIAL-ITEMS,posn(5,2 + 1)))  


orginal-game-state2 = state(character(posn(7,2), "w"), 
  100, INITIAL-ITEMS)

new-game-state2 = state(character(posn(7 + 1,2), "d"), 
  100,
  remove-item(INITIAL-ITEMS,posn(7 + 1,2))) 

#############################
### Key-Pressed Functions ###
#############################

fun key-pressed(start-game-state :: GameState, direction :: String) 
  -> GameState: 
  doc: ```Takes in a GameState and a String (indicating the
          key that's pressed). Returns a GameState where the Posn 
          of the character has moved in the direction the key is 
          pressed. Depending on the Posn moved to,components of the 
          GameState may also be modified.```    
  updated-char-posn = new-char-posn(direction,start-game-state)
  if not(is-a-wall(maze-data, updated-char-posn)) and 
    (L.member(KEYS, direction)):           
    fun new-stamina(lst :: List<Item>) -> Number:
      doc: ```Changes the stamina number depending on 
              the item the character picks up in-game.```
      cases(List) lst: 
        | empty => start-game-state.stamina - 1 
        | link(fst,rst) => if (fst.position == updated-char-posn): 
            cases(Item) fst: 
              |apple(pos, img) =>   INITIAL-STAMINA 
              |tomato(pos ,img) => start-game-state.stamina + 
                (TOMATO-AFFECT - 1)
              |banana(pos , img) => if (start-game-state.stamina >= 80):
                  INITIAL-STAMINA - 1

                else: 
                  start-game-state.stamina + (BANANA-AFFECT - 1)
                end 
            end 
          else: 
            new-stamina(rst)
          end
      end
    end

    updated-stamina =  new-stamina(start-game-state.items) 

    updated-items = remove-item(start-game-state.items, updated-char-posn)

    state(character(updated-char-posn,direction), 
      updated-stamina,updated-items)
  else if L.member(KEYS,direction): 

    state(character(start-game-state.char.position,direction),
      start-game-state.stamina,start-game-state.items) 
  else: 
    start-game-state
  end 

where: 
  key-pressed(orginal-game-state, "w") is new-game-state 
  #if case/tomato case
  key-pressed(orginal-game-state ,"a") is 
  state(character(posn(4,3), "a"),100, 
    table-to-list-items(item-data))
  #if else case  
  key-pressed(orginal-game-state, "f") is orginal-game-state 
  #else case 
  key-pressed(orginal-game-state1, "s") is new-game-state1 
  #if case/banana case 
  key-pressed(orginal-game-state2, "d") is new-game-state2
  #if case/apple case 
end 

##############################
## Functions to Create Maze ##
############################## 

fun convert-string-to-img(inner-lst :: List<String>) -> Image:
  doc: ```Given a list of strings, outputs a wall or ground 
          block depending on the list element (x or o).```
  cases(List) inner-lst: 
    |empty => empty-image
    |link(fst,rst) => if "o" == fst:   
        beside(GROUND, convert-string-to-img(rst))
      else:  
        beside(WALL, convert-string-to-img(rst))
      end 
  end
end  

fun create-maze(lst :: List<List<String>>) -> List<Image>:
  doc: ```Creates rows of the maze to be put together, 
          each within the list as a long image list element.```
  cases(List) lst: 
    |empty => empty
    |link(fst,rst) => link(convert-string-to-img(fst),
        create-maze(rst))
  end
end 

fun final-maze(lst :: List<List<String>>) -> Image:
  doc: ```Uses both create-maze and convert-string-to-img 
          to assemble the maze from strings of either x or o.```
  temp-list = create-maze(lst) 
  fun stack-images(inner-list :: List<Image>)-> Image: 
    cases(List) inner-list: 
      |empty => empty-image
      |link(fst,rst) => above(fst, stack-images(rst))
    end 
  end    
  stack-images(temp-list)
end   

#############################
## More Static Definitions ##
#############################

##### Dimenisons #####
IMAGE-LENGTH = 30 
MAZE-Y-LENGTH = L.length(maze-data)
MAZE-X-LENGTH = L.length(maze-data.get(0))
MAZE-HEIGHT = MAZE-Y-LENGTH * IMAGE-LENGTH
MAZE-WIDTH = MAZE-X-LENGTH * IMAGE-LENGTH

##### Background #####
MAZE-BACKGROUND = final-maze(maze-data) 

##### Final-Posn #####
FINAL-POSN = convert-x-y(posn(35,15))

#############################################
## Helper Function: Change Character Image ##
#############################################  

fun character-img(press :: String) -> Image :
  doc: ```Given a String indicating the button pressed
          (must be "a", "s","d", or "w". Produces an Image,
          which is the character's orientation in the direction 
          it is moving.```
  if string-equal(press,"w"): 
    UP
  else if string-equal(press,"s"): 
    DOWN
  else if string-equal(press,"d"): 
    RIGHT 
  else:  
    LEFT 
  end   
where: 
  character-img("w") is UP #"w" case 
  character-img("s") is DOWN #"s" vase 
  character-img("d") is RIGHT #"d" vase 
  character-img("a") is LEFT #"a"case
end

##########################
### Draw-Game Function ###
##########################

fun draw-game(game-state :: GameState) -> Image:
  doc: ```Given a GameState, produces the interactable game 
          screen that  can change depending on the items 
          picked up,the stamina, the direction the character 
          is moving, and more.```
  fun place-items(items-list :: List<Item>) -> Image: 
    cases(List) items-list:  
      |empty => MAZE-BACKGROUND
      |link(fst,rst) => 
        place-image(fst.img,convert-x-y(fst.position).x,
          convert-x-y(fst.position).y,place-items(rst))
    end 
  end  

  if not((game-state.char.position) == FINAL-POSN):
    
    new-posn = convert-x-y(game-state.char.position)
    
    updated-char-img = character-img(game-state.char.direction)                          

    food-maze = place-items(game-state.items)
    
    items-maze = place-image(updated-char-img, new-posn.x,
      new-posn.y, food-maze)

    yellow-height = num-round(((game-state.stamina / 100)
          * MAZE-HEIGHT))
    
    staminia-bar = overlay-align("center", "bottom", 
      rectangle(IMAGE-LENGTH,
        yellow-height,"solid", "yellow"), 
      rectangle(IMAGE-LENGTH,MAZE-HEIGHT,"solid", "gray"))
    
    beside(items-maze, staminia-bar)
  else: 
    MAZE-BACKGROUND
  end 
end 

##############################
### Game-Complete Function ###
##############################

fun game-complete(g :: GameState) -> Boolean:
  doc: ```Given a GameState, if the character's position 
          is the end position, produce a Boolean 
          to be used to determine when close-when-stop.```
  (convert-x-y(g.char.position) == FINAL-POSN) or (g.stamina == 0)
where: 
  game-complete(orginal-game-state) is false #false case/first or
  game-complete(new-game-state) is false #false case/first or
  game-complete(state(character(posn(35,15),"a"), 50, INITIAL-ITEMS))
    is true
  #true case/first or  
  game-complete(state(character(posn(10,2),"a"), 100, INITIAL-ITEMS))
    is false
  #false case/second or 
  game-complete(state(character(posn(10,2),"a"), 0, INITIAL-ITEMS))
    is true
  #true case/second or
end 

#############
## Reactor ##
#############

maze-game =
  reactor:
    init              : INITIAL-STATE, 
    to-draw           : draw-game,
    # on-mouse        : mouse-click, # portals only
    on-key            : key-pressed,
    stop-when          : game-complete, 
    close-when-stop : true,
    title             : "Magical Mystical Maze!"
  end

interact(maze-game)
