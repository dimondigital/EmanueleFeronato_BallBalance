package {
	  import flash.display.Sprite;
	  import flash.events.Event;
	  import flash.events.MouseEvent;
	 
	 public class Main extends Sprite {
		private var balance:balance_mc=new balance_mc();
		private var gameArray:Array;
		private var ball:ball_mc;
		private var selCol:int;
		private var selRow:int;
		private var gameStatus:String="placing";
		private var chainArray:Array;
		
		public function Main() {
		  prepareArray();
		  buildBalance();
		  addEventListener(Event.ENTER_FRAME,onEnterFrm);
		  stage.addEventListener(MouseEvent.CLICK,onClick);
		}
		
		private function buildBalance():void {
		  var fulcrum:fulcrum_mc = new fulcrum_mc();
		  addChild(fulcrum);
		  fulcrum.x=320;
		  fulcrum.y=480;
		  addChild(balance);
		  balance.x=320;
		  balance.y=430;
		}
		
		private function prepareArray():void {
		  gameArray = new Array();
		  for (var i:uint=0; i<6; i++) {
			gameArray[i]=new Array();
			for (var j:uint=0; j<8; j++) {
			  gameArray[i].push(0);
			}
		  }
		}
		
		private function onEnterFrm(e:Event):void {
			switch (gameStatus) {
				case "placing" :
				  addBall();
				  gameStatus="moving";
				  break;
				case "moving" :
				  selCol=Math.floor((balance.mouseX+200)/50);
				  if (selCol<0) {
					selCol=0;
				  }
				  if (selCol>7) {
					selCol=7;
				  }
				  ball.x=-175+selCol*50;
				  break;
			    case "falling" :
				  ball.y+=12.5;
				  if ((ball.y-25)%50==0) {
					selRow = -1*(ball.y+25)/50;
					if (selRow==0||gameArray[selRow-1][selCol]!=0) {
					  var placedBall:ball_mc = new ball_mc();
					  balance.addChild(placedBall);
					  placedBall.x=ball.x;
					  placedBall.y=ball.y;
					  placedBall.gotoAndStop(ball.currentFrame);
					   placedBall.weight.text=ball.weight.text;
					  placedBall.name=selRow+"_"+selCol;
					  gameArray[selRow][selCol]=placedBall.currentFrame;
					  balance.removeChild(ball);
					  gameStatus="checking";
					}
				  }
				  break;
				case "checking" :
					  chainArray = new Array();
					  gameStatus="placing";
					  for (var i:uint=0; i<6; i++) {
						for (var j:uint=0; j<8; j++) {
						  if (gameArray[i][j]!=0) {
							checkForChains(i,j);
						  }
						}
					  }
					break;
					case "removing" :
					  for (i=0; i<chainArray.length; i++) {
						with (balance) {
						  getChildByName(chainArray[i]).alpha-=0.2;
						  if (getChildByName(chainArray[i]).alpha<0) {
							removeChild(getChildByName(chainArray[i]));
							var parts:Array=chainArray[i].split("_");
							gameArray[parts[0]][parts[1]]=0;
							gameStatus="adjusting";
						  }
						}
					  }
					  break;
					  case "adjusting" :
						  var adjusted:Boolean=false;
						  for (i=1; i<6; i++) {
							for (j=0; j<8; j++) {
							  if (gameArray[i][j]!=0&&gameArray[i-1][j]==0) {
								 adjusted=true;
								with (balance) {
								  getChildByName(i+"_"+j).y+=12.5;
								  if((getChildByName(i+"_"+j).y-25)%50==0){
									getChildByName(i+"_"+j).name=(i-1)+"_"+j;
									gameArray[i-1][j]=gameArray[i][j];
									gameArray[i][j]=0;
								  }
								}
							  }
							}
						  }
						  if (! adjusted) {
							gameStatus="checking";
						  }
						  break; 
				}
				var weight:int=0;
				  for (i=0; i<6; i++) {
					for (j=0; j<8; j++) {
					  if (gameArray[i][j]!=0) {
						var tmpBall:ball_mc;
						tmpBall=balance.getChildByName(i+"_"+j) as ball_mc;
						var tmpWeight:uint=int(tmpBall.weight.text);
						if (j<=3) {
						  weight+=(j-4)*tmpWeight;
						}
						else {
						  weight+=(j-3)*tmpWeight;
						}
					  }
					}
				  }
				  balance.rotation+=weight/100;
			}
			
			private function addBall():void {
			  ball=new ball_mc();
			  balance.addChild(ball);
			  ball.y=-325;
			  ball.gotoAndStop(Math.ceil(Math.random()*6));
			  ball.weight.text=Math.ceil(Math.random()*5).toString();
			}
			
			private function onClick(e:MouseEvent):void {
			  if (gameStatus=="moving"&&gameArray[5][selCol]==0) {
				gameStatus="falling";
			  }
			}
			
			private function checkBall(row:int,col:int):int {
			  if (gameArray[row]==null) {
				return -1;
			  }
			  if (gameArray[row][col]==null) {
				return -1;
			  }
			  return gameArray[row][col];
			}
			
			private function checkHorizontal(row:uint,col:uint):void {
				  var current:uint=gameArray[row][col];
				  var streak:Array=[row.toString()+"_"+col.toString()];
				  var tmpCol:int=col;
				  while (checkBall(row,tmpCol-1)==current) {
					streak.push(row.toString()+"_"+(tmpCol-1).toString());
					tmpCol--;
				  }
				  tmpCol=col;
				  while (checkBall(row,tmpCol+1)==current) {
					streak.push(row.toString()+"_"+(tmpCol+1).toString());
					tmpCol++;
					}
				  if (streak.length>2) {
					gameStatus="removing";
					chainArray=chainArray.concat(streak);
				  }
				}
				
				private function checkVertical(row:uint,col:uint):void {
				  var current:uint=gameArray[row][col];
				  var streak:Array=[row.toString()+"_"+col.toString()];
				  var tmpRow:int=row;
				  while (checkBall(tmpRow-1,col)==current) {
					streak.push((tmpRow-1).toString()+"_"+col.toString());
					tmpRow--;
				  }
				  tmpRow=row;
				  while (checkBall(tmpRow+1,col)==current) {
					streak.push((tmpRow+1).toString()+"_"+col.toString());
					tmpRow++;
				  }
				  if (streak.length>2) {
					gameStatus="removing";
					chainArray=chainArray.concat(streak);
				  }
				}
				
				private function checkDiagonal(row:uint,col:uint):void {
					  var tmpStr:String;
					  var current:uint=gameArray[row][col];
					  var streak:Array=[row.toString()+"_"+col.toString()];
					  var tmpRow:int=row;
					  var tmpCol:int=col;
					  while (checkBall(tmpRow-1,tmpCol-1)==current) {
						tmpStr=(tmpRow-1).toString()+"_"+(tmpCol-1).toString()
						streak.push(tmpStr);
						tmpRow--;
						tmpCol--;
					  }
					  tmpCol=col;
					  tmpRow=row;
					  while (checkBall(tmpRow+1,tmpCol+1)==current) {
						tmpStr=(tmpRow+1).toString()+"_"+(tmpCol+1).toString()
						streak.push(tmpStr);
						tmpRow++;
						tmpCol++;
					  }
					  if (streak.length>2) {
						gameStatus="removing";
						chainArray=chainArray.concat(streak);
					  }
					}
					
					private function checkDiagonal2(row:uint,col:uint):void {
						  var tmpStr:String;
						  var current:uint=gameArray[row][col];
						  var streak:Array=[row.toString()+"_"+col.toString()];
						  var tmpRow:int=row;
						  var tmpCol:int=col;
						  while (checkBall(tmpRow+1,tmpCol-1)==current) {
							tmpStr=(tmpRow+1).toString()+"_"+(tmpCol-1).toString();
							streak.push(tmpStr);
							tmpRow++;
							tmpCol--;
						  }
						  tmpCol=col;
						  tmpRow=row;
						  while (checkBall(tmpRow-1,tmpCol+1)==current) {
							tmpStr=(tmpRow-1).toString()+"_"+(tmpCol+1).toString();
							streak.push(tmpStr);
							tmpRow--;
							tmpCol++;
						  }
						  if (streak.length>2) {
							gameStatus="removing";
							chainArray=chainArray.concat(streak);
						  }
						}
						
					private function checkForChains(row:uint,col:uint):void {
						  checkHorizontal(row,col);
						  checkVertical(row,col);
						  checkDiagonal(row,col);
						  checkDiagonal2(row,col);
						  if (gameStatus=="removing") {
							for (var i:uint = 0; i <chainArray.length - 1; i++) {
							  for (var j:uint = i + 1; j <chainArray.length; j++){
								if (chainArray[i]===chainArray[j]) {
								  chainArray.splice(j, 1);
								}
							  }
							}
						  }
						}   
	  }
	}