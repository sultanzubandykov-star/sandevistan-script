local P=game:GetService("Players")
local R=game:GetService("RunService")
local T=game:GetService("TweenService")
local L=game:GetService("Lighting")
local plr=P.LocalPlayer
local cam=workspace.CurrentCamera

local act,rep=false,false
local pts,imgs={},{}
local ghost,mConn,tThr=nil,nil,nil
local mult,inv,dashSpd,defFov=3.5,0.16,6,70
local COLS={Color3.fromRGB(0,255,170),Color3.fromRGB(0,200,255),Color3.fromRGB(255,50,100),Color3.fromRGB(180,255,0)}
local cIdx=1

local pg=plr:WaitForChild("PlayerGui")
if pg:FindFirstChild("SndUI") then pg.SndUI:Destroy() end
local gui=Instance.new("ScreenGui",pg)
gui.Name="SndUI"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true

local vig=Instance.new("ImageLabel",gui)
vig.Size=UDim2.new(1,0,1,0)
vig.BackgroundTransparency=1
vig.Image="rbxassetid://4576475446"
vig.ImageColor3=Color3.fromRGB(0,20,15)
vig.ImageTransparency=1
vig.Active=false

local cc=L:FindFirstChild("SndCC") or Instance.new("ColorCorrectionEffect",L)
cc.Name="SndCC"

local function btn(txt,sz,pos,col)
	local b=Instance.new("TextButton",gui)
	b.Size,b.Position,b.Text=sz,pos,txt
	b.BackgroundColor3=Color3.fromRGB(15,20,25)
	b.BorderColor3=col or Color3.fromRGB(0,255,170)
	b.BorderSizePixel=2
	b.TextColor3=b.BorderColor3
	b.Font=Enum.Font.GothamBold
	b.TextScaled=true
	b.ZIndex=10
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
	local pad=Instance.new("UIPadding",b)
	pad.PaddingLeft=UDim.new(0,4)
	pad.PaddingRight=UDim.new(0,4)
	pad.PaddingTop=UDim.new(0,4)
	pad.PaddingBottom=UDim.new(0,4)
	return b
end

local tBtn=btn("САНДЕВИСТАН: ВЫКЛ",UDim2.new(0,210,0,42),UDim2.new(0.75,-105,0.28,0))
local bM=btn("БЕГ: СРЕД",UDim2.new(0,66,0,32),UDim2.new(0.75,-105,0.28,48))
local bF=btn("БЕГ: БЫСТР",UDim2.new(0,66,0,32),UDim2.new(0.75,-33,0.28,48))
local bN=btn("БЕГ: ОБЫЧ",UDim2.new(0,66,0,32),UDim2.new(0.75,39,0.28,48))
local dS=btn("РЫВ: МЕДЛ",UDim2.new(0,66,0,32),UDim2.new(0.75,-105,0.28,86),Color3.fromRGB(0,200,255))
local dM=btn("РЫВ: СРЕД",UDim2.new(0,66,0,32),UDim2.new(0.75,-33,0.28,86),Color3.fromRGB(0,200,255))
local dF=btn("РЫВ: МОЛН",UDim2.new(0,66,0,32),UDim2.new(0.75,39,0.28,86),Color3.fromRGB(0,200,255))

local function setR(m,i,a)
	mult,inv=m,i
	for _,b in ipairs({bM,bF,bN}) do
		b.BackgroundColor3=(b==a) and Color3.fromRGB(0,110,80) or Color3.fromRGB(15,20,25)
		b.TextColor3=(b==a) and Color3.new(1,1,1) or Color3.fromRGB(0,255,170)
	end
end
local function setD(s,a)
	dashSpd=s
	for _,b in ipairs({dS,dM,dF}) do
		b.BackgroundColor3=(b==a) and Color3.fromRGB(0,95,130) or Color3.fromRGB(15,20,25)
		b.TextColor3=(b==a) and Color3.new(1,1,1) or Color3.fromRGB(0,200,255)
	end
end
bM.MouseButton1Click:Connect(function() setR(3.5,0.16,bM) end)
bF.MouseButton1Click:Connect(function() setR(6.5,0.11,bF) end)
bN.MouseButton1Click:Connect(function() setR(1.5,0.22,bN) end)
dS.MouseButton1Click:Connect(function() setD(2.5,dS) end)
dM.MouseButton1Click:Connect(function() setD(6,dM) end)
dF.MouseButton1Click:Connect(function() setD(14,dF) end)
setR(3.5,0.16,bM) setD(6,dM)

local function atm(on)
	local ti=TweenInfo.new(0.3)
	if on then
		defFov=cam.FieldOfView
		T:Create(cam,ti,{FieldOfView=95}):Play()
		T:Create(vig,ti,{ImageTransparency=0.25}):Play()
		T:Create(cc,ti,{TintColor=Color3.fromRGB(190,255,235),Saturation=0.25,Contrast=0.15}):Play()
	else
		T:Create(cam,ti,{FieldOfView=defFov}):Play()
		T:Create(vig,ti,{ImageTransparency=1}):Play()
		T:Create(cc,ti,{TintColor=Color3.new(1,1,1),Saturation=0,Contrast=0}):Play()
	end
end

local function fade(m)
	if not m or not m.Parent then return end
	for _,p in ipairs(m:GetDescendants()) do
		if p:IsA("BasePart") then T:Create(p,TweenInfo.new(0.18),{Transparency=1}):Play() end
	end
	task.delay(0.2,function() if m then m:Destroy() end end)
end

local function mkGhost(ch)
	ch.Archivable=true
	for _,v in ipairs(ch:GetDescendants()) do v.Archivable=true end
	local cl=ch:Clone()
	ch.Archivable=false
	if not cl then return nil end
	for _,v in ipairs(cl:GetDescendants()) do
		if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ForceField") then v:Destroy()
		elseif v:IsA("BasePart") then
			v.Anchored=false
			v.CanCollide=(v.Name=="HumanoidRootPart")
			v.CanTouch,v.CanQuery,v.Massless=false,false,true
			if v.Name~="HumanoidRootPart" and v.Transparency<0.95 then
				v.Material,v.Color,v.Transparency=Enum.Material.Neon,Color3.fromRGB(0,255,170),0.3
			end
		end
	end
	cl.Parent=workspace
	local h=cl:FindFirstChildOfClass("Humanoid")
	if h then
		h.AutoRotate=false
		local an=h:FindFirstChildOfClass("Animator") or Instance.new("Animator",h)
		local a=Instance.new("Animation")
		a.AnimationId=(h.RigType==Enum.HumanoidRigType.R15) and "rbxassetid://507767714" or "rbxassetid://180426354"
		local ok,tr=pcall(function() return an:LoadAnimation(a) end)
		if ok and tr then
			tr.Looped=true
			h.Running:Connect(function(s)
				if s>0.5 then if not tr.IsPlaying then tr:Play() end tr:AdjustSpeed(math.clamp(s/16,1,2.5))
				elseif tr.IsPlaying then tr:Stop() end
			end)
		end
	end
	return cl
end

local function mkSil(src,col,tr)
	local cfs={}
	src.Archivable=true
	for _,v in ipairs(src:GetDescendants()) do
		v.Archivable=true
		if v:IsA("BasePart") then cfs[v.Name..tostring(v.Size)]=v.CFrame end
	end
	local cl=src:Clone()
	src.Archivable=false
	if not cl then return nil end
	for _,v in ipairs(cl:GetDescendants()) do
		if v:IsA("BasePart") then
			if v.Name=="HumanoidRootPart" or v.Transparency>=0.95 then v:Destroy()
			else
				local cf=cfs[v.Name..tostring(v.Size)]
				v.Anchored,v.CanCollide,v.CanTouch,v.CanQuery,v.Massless,v.CastShadow=true,false,false,false,true,false
				v.Material,v.Color,v.Transparency=Enum.Material.Neon,col,tr
				if cf then v.CFrame=cf end
			end
		elseif v:IsA("JointInstance") or v:IsA("WeldConstraint") or v:IsA("Humanoid") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Animator") or v:IsA("Decal") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("SurfaceAppearance") then v:Destroy()
		elseif v:IsA("SpecialMesh") then v.TextureId=""
		elseif v:IsA("MeshPart") then v.TextureID="" end
	end
	cl.Parent=workspace
	return cl
end

local function start()
	local ch=plr.Character
	local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
	local hum=ch and ch:FindFirstChild("Humanoid")
	if not hrp or not hum or rep then return end
	act=true
	pts={}
	table.insert(pts,hrp.CFrame)
	for _,d in ipairs(imgs) do if d.m then d.m:Destroy() end end
	table.clear(imgs)
	if ghost then ghost:Destroy() ghost=nil end

	tBtn.Text="САНДЕВИСТАН: ВКЛ"
	tBtn.BackgroundColor3=Color3.fromRGB(0,80,60)
	atm(true)
	hrp.Anchored=true

	ghost=mkGhost(ch)
	local gHrp=ghost and ghost:FindFirstChild("HumanoidRootPart")
	local gHum=ghost and ghost:FindFirstChild("Humanoid")
	if gHrp and gHum then
		gHrp.CFrame=hrp.CFrame
		cam.CameraSubject=gHum
		mConn=R.Heartbeat:Connect(function()
			if not act or not gHrp.Parent then return end
			local dir=hum.MoveDirection
			gHum.WalkSpeed=hum.WalkSpeed*mult
			gHum:Move(dir,false)
			if dir.Magnitude>0.05 then
				local flatDir=Vector3.new(dir.X,0,dir.Z).Unit
				gHrp.CFrame=CFrame.lookAt(gHrp.Position,gHrp.Position+flatDir)
			else
				-- Убираем скольжение фантома при остановке
				local vel=gHrp.AssemblyLinearVelocity
				gHrp.AssemblyLinearVelocity=Vector3.new(0,vel.Y,0)
			end
			if hum.Jump then gHum.Jump=true end
			local last=pts[#pts]
			if not last or (gHrp.Position-last.Position).Magnitude>0.2 then table.insert(pts,gHrp.CFrame) end
		end)
		tThr=task.spawn(function()
			while act and ghost and ghost.Parent do
				local col=COLS[cIdx] cIdx=(cIdx%#COLS)+1
				local s=mkSil(ghost,col,0.45)
				if s then table.insert(imgs,{m=s,i=math.max(1,#pts),ok=false}) end
				task.wait(inv)
			end
		end)
	end
end

local function stop()
	if not act then return end
	act,rep=false,true
	tBtn.Text="РЫВОК..."
	tBtn.BackgroundColor3=Color3.fromRGB(160,110,0)
	if mConn then mConn:Disconnect() mConn=nil end
	if tThr then task.cancel(tThr) tThr=nil end
	if ghost then ghost:Destroy() ghost=nil end

	local ch=plr.Character
	local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
	local hum=ch and ch:FindFirstChild("Humanoid")
	if hum then cam.CameraSubject=hum end

	local total=#pts
	if hrp and total>1 then
		local step=math.max(1,math.floor(dashSpd))
		for idx=1,total,step do
			if not hrp or not hrp.Parent then break end
			hrp.CFrame=pts[idx]
			for _,d in ipairs(imgs) do
				if not d.ok and d.i<=idx then
					d.ok=true
					fade(d.m)
				end
			end
			R.Heartbeat:Wait()
		end
		if hrp and hrp.Parent then
			hrp.CFrame=pts[total]
		end
	end

	for _,d in ipairs(imgs) do
		if not d.ok then fade(d.m) end
	end
	table.clear(imgs)
	table.clear(pts)

	if hrp and hrp.Parent then
		hrp.Anchored=false
		hrp.AssemblyLinearVelocity=Vector3.zero
	end

	atm(false)
	tBtn.Text="САНДЕВИСТАН: ВЫКЛ"
	tBtn.BackgroundColor3=Color3.fromRGB(15,20,25)
	rep=false
end

tBtn.MouseButton1Click:Connect(function()
	if act then stop() else start() end
end)

plr.CharacterAdded:Connect(function()
	act,rep=false,false
	if mConn then mConn:Disconnect() mConn=nil end
	if tThr then task.cancel(tThr) tThr=nil end
	if ghost then ghost:Destroy() ghost=nil end
	for _,d in ipairs(imgs) do if d.m then d.m:Destroy() end end
	table.clear(imgs)
	table.clear(pts)
	atm(false)
	tBtn.Text="САНДЕВИСТАН: ВЫКЛ"
	tBtn.BackgroundColor3=Color3.fromRGB(15,20,25)
end)