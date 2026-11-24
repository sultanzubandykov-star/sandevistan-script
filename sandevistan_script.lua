local P=game:GetService("Players")
local R=game:GetService("RunService")
local T=game:GetService("TweenService")
local L=game:GetService("Lighting")
local U=game:GetService("UserInputService")
local plr=P.LocalPlayer
local cam=workspace.CurrentCamera
local act,rep,mode=false,false,1
local pts,imgs={},{}
local ghost,mConn,tThr=nil,nil,nil
local mult,inv,dashSpd,defFov=5.0,0.14,14,70
local COLS={Color3.fromRGB(0,255,170),Color3.fromRGB(0,200,255),Color3.fromRGB(255,50,100),Color3.fromRGB(180,255,0)}
local cIdx=1
local target=plr:WaitForChild("PlayerGui")
if target:FindFirstChild("SndUI") then target.SndUI:Destroy() end
local gui=Instance.new("ScreenGui",target)
gui.Name="SndUI" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=999999
local vig=Instance.new("ImageLabel",gui)
vig.Size=UDim2.new(1,0,1,0) vig.BackgroundTransparency=1 vig.Image="rbxassetid://4576475446" vig.ImageColor3=Color3.fromRGB(0,20,15) vig.ImageTransparency=1 vig.Active=false vig.ZIndex=1
local cc=L:FindFirstChild("SndCC") or Instance.new("ColorCorrectionEffect",L)
cc.Name="SndCC"
local menuBox=Instance.new("Frame",gui)
menuBox.Size=UDim2.new(0,210,0,154) menuBox.Position=UDim2.new(0.75,-105,0.28,-36) menuBox.BackgroundTransparency=1 menuBox.ZIndex=9
local wasDragged=false
local function hookMenuDrag(el)
	local dIn,dStart,sPos=nil,nil,nil
	el.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
			dIn,dStart,sPos,wasDragged=i,i.Position,menuBox.Position,false
		end
	end)
	U.InputChanged:Connect(function(i)
		if dIn and (i==dIn or i.UserInputType==Enum.UserInputType.MouseMovement) then
			local delta=i.Position-dStart
			if delta.Magnitude>10 then wasDragged=true end
			if wasDragged then
				menuBox.Position=UDim2.new(sPos.X.Scale,sPos.X.Offset+delta.X,sPos.Y.Scale,sPos.Y.Offset+delta.Y)
			end
		end
	end)
	U.InputEnded:Connect(function(i) if i==dIn then dIn=nil task.defer(function() wasDragged=false end) end end)
end
local function btn(par,txt,sz,pos,col)
	local b=Instance.new("TextButton",par)
	b.Size,b.Position,b.Text=sz,pos,txt
	b.BackgroundColor3=Color3.fromRGB(15,20,25) b.BorderColor3=col or Color3.fromRGB(0,255,170) b.BorderSizePixel=2
	b.TextColor3=b.BorderColor3 b.Font=Enum.Font.GothamBold b.TextScaled=true b.ZIndex=10
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
	hookMenuDrag(b)
	return b
end
local hBtn=btn(menuBox,"СКРЫТЬ",UDim2.new(0,72,0,30),UDim2.new(0,0,0,0),Color3.fromRGB(255,200,0))
local mBtn=btn(menuBox,"РЕЖИМ: КЛОНЫ",UDim2.new(0,132,0,30),UDim2.new(0,78,0,0),Color3.fromRGB(255,50,100))
local tBtn=btn(menuBox,"САНДЕВИСТАН: ВЫКЛ",UDim2.new(0,210,0,42),UDim2.new(0,0,0,36))
local bM=btn(menuBox,"БЕГ: СРЕД",UDim2.new(0,66,0,32),UDim2.new(0,0,0,84))
local bF=btn(menuBox,"БЕГ: БЫСТР",UDim2.new(0,66,0,32),UDim2.new(0,72,0,84))
local bN=btn(menuBox,"БЕГ: ОБЫЧ",UDim2.new(0,66,0,32),UDim2.new(0,144,0,84))
local dS=btn(menuBox,"РЫВ: МЕДЛ",UDim2.new(0,66,0,32),UDim2.new(0,0,0,122),Color3.fromRGB(0,200,255))
local dM=btn(menuBox,"РЫВ: СРЕД",UDim2.new(0,66,0,32),UDim2.new(0,72,0,122),Color3.fromRGB(0,200,255))
local dF=btn(menuBox,"РЫВ: МОЛН",UDim2.new(0,66,0,32),UDim2.new(0,144,0,122),Color3.fromRGB(0,200,255))
local vis=true
local function updateVis()
	mBtn.Visible=vis tBtn.Visible=vis bM.Visible=vis bF.Visible=vis bN.Visible=vis
	local showDash=vis and (mode==1)
	dS.Visible=showDash dM.Visible=showDash dF.Visible=showDash
end
hBtn.MouseButton1Click:Connect(function() if wasDragged then return end vis=not vis hBtn.Text=vis and "СКРЫТЬ" or "МЕНЮ" updateVis() end)
local function setR(m,i,a) if wasDragged then return end mult,inv=m,i for _,b in ipairs({bM,bF,bN}) do b.BackgroundColor3=(b==a) and Color3.fromRGB(0,110,80) or Color3.fromRGB(15,20,25) b.TextColor3=(b==a) and Color3.new(1,1,1) or Color3.fromRGB(0,255,170) end end
local function setD(s,a) if wasDragged then return end dashSpd=s for _,b in ipairs({dS,dM,dF}) do b.BackgroundColor3=(b==a) and Color3.fromRGB(0,95,130) or Color3.fromRGB(15,20,25) b.TextColor3=(b==a) and Color3.new(1,1,1) or Color3.fromRGB(0,200,255) end end
bM.MouseButton1Click:Connect(function() setR(5.0,0.14,bM) end) bF.MouseButton1Click:Connect(function() setR(9.0,0.09,bF) end) bN.MouseButton1Click:Connect(function() setR(2.4,0.19,bN) end)
dS.MouseButton1Click:Connect(function() setD(6,dS) end) dM.MouseButton1Click:Connect(function() setD(14,dM) end) dF.MouseButton1Click:Connect(function() setD(28,dF) end)
setR(5.0,0.14,bM) setD(14,dM)
local function atm(on)
	local ti=TweenInfo.new(0.3)
	if on then defFov=cam.FieldOfView T:Create(cam,ti,{FieldOfView=95}):Play() T:Create(vig,ti,{ImageTransparency=0.25}):Play() T:Create(cc,ti,{TintColor=Color3.fromRGB(190,255,235),Saturation=0.25,Contrast=0.15}):Play()
	else T:Create(cam,ti,{FieldOfView=defFov}):Play() T:Create(vig,ti,{ImageTransparency=1}):Play() T:Create(cc,ti,{TintColor=Color3.new(1,1,1),Saturation=0,Contrast=0}):Play() end
end
local function fade(m,dur)
	if not m or not m.Parent then return end
	local d=dur or 0.15
	for _,p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") then T:Create(p,TweenInfo.new(d),{Transparency=1}):Play() end end
	task.delay(d+0.02,function() if m then m:Destroy() end end)
end
local function mkSil(src,col,tr)
	local cfs={} src.Archivable=true
	for _,v in ipairs(src:GetDescendants()) do v.Archivable=true if v:IsA("BasePart") then cfs[v.Name..tostring(v.Size)]=v.CFrame end end
	local cl=src:Clone() src.Archivable=false
	if not cl then return nil end
	for _,v in ipairs(cl:GetDescendants()) do
		if v:IsA("BasePart") then
			if v.Name=="HumanoidRootPart" or v.Transparency>=0.95 then v:Destroy()
			else local c=cfs[v.Name..tostring(v.Size)] v.Anchored,v.CanCollide,v.CanTouch,v.CanQuery,v.Massless,v.CastShadow=true,false,false,false,true,false v.Material,v.Color,v.Transparency=Enum.Material.Neon,col,tr if c then v.CFrame=c end end
		elseif v:IsA("JointInstance") or v:IsA("WeldConstraint") or v:IsA("Humanoid") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Animator") or v:IsA("Decal") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("SurfaceAppearance") then v:Destroy()
		elseif v:IsA("SpecialMesh") then v.TextureId="" elseif v:IsA("MeshPart") then v.TextureID="" end
	end
	cl.Parent=workspace
	return cl
end
local function mkGhost(ch)
	ch.Archivable=true for _,v in ipairs(ch:GetDescendants()) do v.Archivable=true end
	local cl=ch:Clone() ch.Archivable=false if not cl then return nil end
	for _,v in ipairs(cl:GetDescendants()) do
		if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ForceField") then v:Destroy()
		elseif v:IsA("BasePart") then
			v.Anchored=false v.CanCollide=(v.Name=="HumanoidRootPart") v.CanTouch,v.CanQuery,v.Massless=false,false,true
			if v.Name~="HumanoidRootPart" and v.Transparency<0.95 then v.Material,v.Color,v.Transparency=Enum.Material.Neon,Color3.fromRGB(0,255,170),0.3 end
		end
	end
	cl.Parent=workspace
	local h=cl:FindFirstChildOfClass("Humanoid")
	if h then
		h.AutoRotate=false
		local an=h:FindFirstChildOfClass("Animator") or Instance.new("Animator",h)
		local a=Instance.new("Animation") a.AnimationId=(h.RigType==Enum.HumanoidRigType.R15) and "rbxassetid://507767714" or "rbxassetid://180426354"
		local okA,tr=pcall(function() return an:LoadAnimation(a) end)
		if okA and tr then tr.Looped=true h.Running:Connect(function(s) if s>0.5 then if not tr.IsPlaying then tr:Play() end tr:AdjustSpeed(math.clamp(s/16,1,2.5)) elseif tr.IsPlaying then tr:Stop() end end) end
	end
	return cl
end
local oldWS=16
local function start()
	if wasDragged then return end
	local ch=plr.Character
	local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
	local hum=ch and ch:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum or rep then return end
	act=true
	tBtn.Text="САНДЕВИСТАН: ВКЛ" tBtn.BackgroundColor3=Color3.fromRGB(0,110,80) tBtn.TextColor3=Color3.new(1,1,1) atm(true)
	if mode==1 then
		pts={hrp.CFrame}
		for _,d in ipairs(imgs) do if d.m then d.m:Destroy() end end
		table.clear(imgs)
		if ghost then ghost:Destroy() ghost=nil end
		ghost=mkGhost(ch)
		local gHum=ghost and ghost:FindFirstChildOfClass("Humanoid")
		local gHrp=ghost and ghost:FindFirstChild("HumanoidRootPart")
		if not ghost or not gHum or not gHrp then act=false atm(false) return end
		hrp.Anchored=true cam.CameraSubject=gHum
		if mConn then mConn:Disconnect() end
		mConn=R.RenderStepped:Connect(function()
			if not act or not ghost or not gHum or not gHrp or not hum then return end
			local gd=hum.MoveDirection
			if gd.Magnitude>0.05 then
				local ud=Vector3.new(gd.X,0,gd.Z)
				if ud.Magnitude>0.01 then ud=ud.Unit gHum.WalkSpeed=16*mult gHum:Move(ud,false) gHrp.CFrame=CFrame.lookAt(gHrp.Position,gHrp.Position+ud) end
			else gHum:Move(Vector3.zero,false) end
			if hum.Jump then gHum.Jump=true end
		end)
		if tThr then task.cancel(tThr) end
		tThr=task.spawn(function()
			while act and ghost and gHrp do
				local cf,last=gHrp.CFrame,pts[#pts]
				if not last or (cf.Position-last.Position).Magnitude>0.8 then
					table.insert(pts,cf)
					local sil=mkSil(ghost,COLS[cIdx],0.45)
					cIdx=(cIdx%#COLS)+1
					if sil then table.insert(imgs,{m=sil,pos=cf.Position,gone=false}) end
				end
				task.wait(inv)
			end
		end)
	else
		oldWS=hum.WalkSpeed
		if mConn then mConn:Disconnect() end
		mConn=R.RenderStepped:Connect(function()
			if act and hum then hum.WalkSpeed=16*mult end
		end)
		if tThr then task.cancel(tThr) end
		tThr=task.spawn(function()
			local lastP=hrp.Position
			while act and ch and hrp and hrp.Parent do
				if (hrp.Position-lastP).Magnitude>1.2 then
					lastP=hrp.Position
					local sil=mkSil(ch,COLS[cIdx],0.45)
					cIdx=(cIdx%#COLS)+1
					if sil then fade(sil,1.25) end
				end
				task.wait(inv)
			end
		end)
	end
end
local function stop()
	if not act or rep then return end
	act,rep=false,true
	if mConn then mConn:Disconnect() mConn=nil end
	if tThr then task.cancel(tThr) tThr=nil end
	local ch=plr.Character
	local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
	local hum=ch and ch:FindFirstChildOfClass("Humanoid")
	if mode==1 then
		tBtn.Text="РЫВОК..." tBtn.BackgroundColor3=Color3.fromRGB(0,95,130)
		if ghost then local gHrp=ghost:FindFirstChild("HumanoidRootPart") if gHrp then table.insert(pts,gHrp.CFrame) end ghost:Destroy() ghost=nil end
		if hum then cam.CameraSubject=hum end
		if hrp and hum and #pts>1 then
			hrp.Anchored=true local speed=16*dashSpd
			for i=2,#pts do
				if not hrp or not hrp.Parent then break end
				local tCF,sCF=pts[i],hrp.CFrame
				local dist=(tCF.Position-sCF.Position).Magnitude
				if dist>0.05 then
					local dur,el=dist/speed,0
					while el<dur and hrp and hrp.Parent do
						el+=R.RenderStepped:Wait()
						hrp.CFrame=sCF:Lerp(tCF,math.clamp(el/dur,0,1))
						hrp.AssemblyLinearVelocity,hrp.AssemblyAngularVelocity=Vector3.zero,Vector3.zero
						local cp=hrp.Position
						for _,d in ipairs(imgs) do if not d.gone and (cp-d.pos).Magnitude<3.5 then d.gone=true fade(d.m,0.15) end end
					end
					if hrp and hrp.Parent then hrp.CFrame=tCF end
				end
			end
		end
		if hrp and hrp.Parent then hrp.AssemblyLinearVelocity,hrp.Anchored=Vector3.zero,false end
		for _,d in ipairs(imgs) do if not d.gone then d.gone=true fade(d.m,0.15) end end
		table.clear(imgs) table.clear(pts)
	else
		if hum and hum.Parent then hum.WalkSpeed=oldWS end
	end
	atm(false)
	tBtn.Text="САНДЕВИСТАН: ВЫКЛ" tBtn.BackgroundColor3=Color3.fromRGB(15,20,25) tBtn.TextColor3=Color3.fromRGB(0,255,170) rep=false
end
mBtn.MouseButton1Click:Connect(function()
	if wasDragged or act or rep then return end
	mode=(mode==1) and 2 or 1
	mBtn.Text=(mode==1) and "РЕЖИМ: КЛОНЫ" or "РЕЖИМ: УСКОРЕНИЕ"
	mBtn.BorderColor3=(mode==1) and Color3.fromRGB(255,50,100) or Color3.fromRGB(180,255,0)
	mBtn.TextColor3=mBtn.BorderColor3
	updateVis()
end)
tBtn.MouseButton1Click:Connect(function() if not wasDragged and not rep then if act then stop() else start() end end end)
U.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.E and not rep then if act then stop() else start() end end end)
plr.CharacterRemoving:Connect(function()
	act,rep=false,false
	if mConn then mConn:Disconnect() mConn=nil end
	if tThr then task.cancel(tThr) tThr=nil end
	if ghost then ghost:Destroy() ghost=nil end
	for _,d in ipairs(imgs) do if d.m then d.m:Destroy() end end
	table.clear(imgs) table.clear(pts) atm(false)
	local ch=plr.Character
	local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
	if hrp then hrp.Anchored=false end
	tBtn.Text="САНДЕВИСТАН: ВЫКЛ" tBtn.BackgroundColor3=Color3.fromRGB(15,20,25) tBtn.TextColor3=Color3.fromRGB(0,255,170)
end)
