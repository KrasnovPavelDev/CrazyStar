{ In this game, the star moves in a random direction.
  Every 10 steps, you can change the star's direction
  manually using the arrow keys. You need to guide
  the star to the center of the window before 1000 steps }

program CrazyStar;
uses crt;

const
	MaxActions = 1000;

type
	{ Program statuses }
	statuses = (win, lose, play);
	{ Directions in which the star moves }
	sides = (top, bottom, right, left);
	star_info = record
		x, y, actions, usr_mv: integer;
		save_flag: boolean;
		saved_act: sides;
		game_status: statuses;
		side: sides;
	end;

procedure GetKey(var code: integer);
var
	c: char;
begin
	c := ReadKey;
	if c = #0 then
	begin
		c := ReadKey;
		code := -ord(c)
	end
	else
	begin
		code := ord(c)
	end
end;

procedure HideStar(var star: star_info);
begin
	GotoXY(star.x, star.y);
	write(' ');
	GotoXY(1, 1)
end;

procedure DrawStar(var star: star_info);
begin
	GotoXY(star.x, star.y);
	write('*');
	GotoXY(1, 1)
end;

procedure RandomChangeDirection(var star: star_info);
var
	range, sd: integer;
begin
	{ With a 1/10 probability, the star changes its direction }
	range := 10;
	if random(range) = 1 then
	begin
		{ We ensure that the star cannot change to the opposite direction }
		sd := random(2);
		if (star.side = top) or (star.side = bottom) then
			case sd of
				{ We restrict the star's movement }
				0: star.side := left;
				1: star.side := right
			end
		else
			case sd of
				0: star.side := top;
				1: star.side := bottom
			end
	end
end;

{ We ensure the star does not go beyond the screen boundaries }
procedure CheckBorder(var star: star_info);
begin
	if star.x > ScreenWidth then
		star.x := 1;
	if star.x < 1 then
		star.x := ScreenWidth;
	{ We reserve the top row for information }
	if star.y > ScreenHeight then
		star.y := 2;
	if star.y < 2 then
		star.y := ScreenHeight
end;

procedure MoveStar(var star: star_info);
begin
	HideStar(star);
	case star.side of
		right: star.x := star.x + 1;
		left: star.x := star.x - 1;
		top: star.y := star.y - 1;
		bottom: star.y := star.y + 1
	end;
	star.actions := star.actions + 1;
	CheckBorder(star);
	DrawStar(star)
end;

procedure Handling(var star: star_info; ch: integer);
begin
	case ch of
		-77: star.saved_act := right;
		-75: star.saved_act := left;
		-72: star.saved_act := top;
		-80: star.saved_act := bottom
	end;
	star.save_flag := true
end;

{ }
procedure CheckUserMv(var star: star_info);
begin
	if star.save_flag then
		{ The user can change the star's direction only once
		  every 10 movements of the star }
		if (star.actions - star.usr_mv) > 10 then
		begin
			star.side := star.saved_act;
			star.usr_mv := star.actions;
			star.save_flag := false
		end
end;

procedure HideInfo(var star: star_info);
var
	i: integer;
begin
	{ We clear the information line. 30 characters
	  are enough to erase everything }
	for i := 1 to 30 do
		write(' ')
end;

procedure DrawInfo(var star: star_info; maxac: integer);
begin
	HideInfo(star);
	GotoXY(1, 1);
	write('[Actions: ', star.actions, '/', maxac, ']');
	GotoXY(1, 1)
end;

{ We draw the target in the center — the spot
  where the star must be guided to win }
procedure DrawBorder;
var
	i, sx, sy: integer;
begin
	sx := ScreenWidth div 2 - 1;
	sy := ScreenHeight div 2 - 1;
	for i := 0 to 2 do
	begin
		GotoXY(sx+i, sy);
		write('@');
		GotoXY(sx+i, sy+2);
		write('@');
		GotoXY(sx, sy+i);
		write('@');
		GotoXY(sx+2, sy+i);
		write('@')
	end;
	GotoXY(1, 1)
end;

procedure CheckWin(var star: star_info);
var
	wx, wy: integer;
begin
	wx := ScreenWidth div 2;
	wy := ScreenHeight div 2;
	if (star.x = wx) and (star.y = wy) then
		star.game_status := win
end;

procedure CheckLose(var star: star_info; maxac: integer);
begin
	if star.actions >= maxac then
		star.game_status := lose
end;

procedure WinMenu;
var
	msg: string;
begin
	msg := 'YOU WIN';
	clrscr;
	GotoXY(ScreenWidth div 2 - (Length(msg) div 2), ScreenHeight div 2);
	write(msg);
	GotoXY(1, 1)
end;

procedure LoseMenu;
var
	msg: string;
begin
	msg := 'GAME OVER';
	clrscr;
	GotoXY(ScreenWidth div 2 - (Length(msg) div 2), ScreenHeight div 2);
	write(msg);
	GotoXY(1, 1)
end;

var
	dly, c: integer;
	star: star_info;
begin
	randomize;
	dly := 100;
	star.x := 1;
	star.y := 1;
	star.usr_mv := 0;
	star.save_flag := false;
	star.game_status := play;
	star.side := right;
	star.saved_act := right;
	star.actions := 0;
	clrscr;
	while true do
	begin
		if not KeyPressed then
		begin
			if star.game_status = win then
				WinMenu;
			if star.game_status = lose then
				LoseMenu;
			if star.game_status = play then
			begin
				MoveStar(star);
				RandomChangeDirection(star);
				DrawInfo(star, MaxActions);
				CheckUserMv(star);
				DrawBorder;
				CheckWin(star);
				CheckLose(star, MaxActions);
				delay(dly);
				continue
			end
		end;
		GetKey(c);
		case c of
			-77, -75, -72, -80: Handling(star, c);
			27: break
		end
	end;
	clrscr
end.
