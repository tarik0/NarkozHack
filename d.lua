--[[
    Cool Guy's DarkRP Hack
    @author cool guy
    @version 1.1

    Update 1.1:
        Better no-recoil system.
        New menu open hotkey (INSERT).
]]--

-- Set global variables
if (CGH == nil) then
    CGH = {}
    CGH.PrimaryColor = Color(56, 56, 56)
    CGH.SecondaryColor = Color(58, 227, 116)
    CGH.DarkerPrimaryColor = Color(41, 41, 41)
    CGH.CrosshairEnabled = false
    CGH.WallhackEnabled = false
    CGH.NoRecoilEnabled = false
    CGH.RecoilFuncPath = "addons/silahlar/lua/weapons/tfa_gun_base/sh_bullet.lua"
    
    -- Set global console variables
    CGH.CrosshairGapConVar = CreateClientConVar("cgh_crosshair_gap", "4")
    CGH.CrosshairLengthConVar = CreateClientConVar("cgh_crosshair_length", "8")
    CGH.CrosshairThicknessConVar = CreateClientConVar("cgh_crosshair_thickness", "3")
    CGH.CrosshairRedConVar = CreateClientConVar("cgh_crosshair_red", "255")
    CGH.CrosshairGreenConVar = CreateClientConVar("cgh_crosshair_green", "255")
    CGH.CrosshairBlueConVar = CreateClientConVar("cgh_crosshair_blue", "0")
    CGH.CrosshairAlphaConVar = CreateClientConVar("cgh_crosshair_alpha", "200")
    CGH.WhShowAdminConVar = CreateClientConVar("cgh_wh_show_admins", "1")
end

-- CGH:OpenMenu: Opens the hack menu
function CGH:OpenMenu()
    -- Generate the frame
    local frame = vgui.Create("DFrame")
    frame:SetTitle(string.format("%s Cool Guy's Hack Menu V1.1", "            "))
    frame:SetSizable(false)
    frame:SetSize(300, 230)
    frame:SetPos(15, 15)
    frame:SetIcon("icon16/application_xp_terminal.png")
    frame:MakePopup()

    -- Crosshair button
    local crossButton = vgui.Create("DButton", frame)
    crossButton:SetPos(20, 40)
    crossButton:SetSize(260, 50)
    if CGH.CrosshairEnabled == true then crossButton:SetText("Disable Crosshair") else crossButton:SetText("Enable Crosshair") end
    crossButton.DoClick = function()
        CGH.CrosshairEnabled = !CGH.CrosshairEnabled
        if CGH.CrosshairEnabled == true then crossButton:SetText("Disable Crosshair") else crossButton:SetText("Enable Crosshair") end
    end

    -- Wallhack button
    local whButton = vgui.Create("DButton", frame)
    whButton:SetPos(20, 100)
    whButton:SetSize(260, 50)
    if CGH.WallhackEnabled == true then whButton:SetText("Disable Wall Hack") else whButton:SetText("Enable Wall Hack") end
    whButton.DoClick = function()
        CGH.WallhackEnabled = !CGH.WallhackEnabled
        if CGH.WallhackEnabled == true then whButton:SetText("Disable Wall Hack") else whButton:SetText("Enable Wall Hack") end
    end

    -- No Recoil button
    local recoilButton = vgui.Create("DButton", frame)
    recoilButton:SetPos(20, 160)
    recoilButton:SetSize(260, 50)
    if CGH.NoRecoilEnabled == true then recoilButton:SetText("Disable No-Recoil") else recoilButton:SetText("Enable No-Recoil") end
    recoilButton.DoClick = function()
        CGH.NoRecoilEnabled = !CGH.NoRecoilEnabled
        if CGH.NoRecoilEnabled == true then recoilButton:SetText("Disable No-Recoil") else recoilButton:SetText("Enable No-Recoil") end
    end
    
end

-- Add hook for the crosshair
hook.Remove("HUDPaint", "CGH.Crosshair")
hook.Add("HUDPaint", "CGH.Crosshair", function()
    if CGH.CrosshairEnabled == false then return end

	local crosshairGap = math.max(CGH.CrosshairGapConVar:GetFloat(), 0)
	local crosshairLength = math.max(CGH.CrosshairLengthConVar:GetFloat(), 0)
	local crosshairThickness = math.max(CGH.CrosshairThicknessConVar:GetFloat(), 0)
	local crosshairRed = math.Clamp(CGH.CrosshairRedConVar:GetInt(), 0, 255)
	local crosshairGreen = math.Clamp(CGH.CrosshairGreenConVar:GetInt(), 0, 255)
	local crosshairBlue = math.Clamp(CGH.CrosshairBlueConVar:GetInt(), 0, 255)
	local crosshairAlpha = math.Clamp(CGH.CrosshairAlphaConVar:GetInt(), 0, 255)
	
	local xCenter = ScrW() / 2
	local yCenter = ScrH() / 2
	
	local crosshairThicknessHalf = crosshairThickness / 2
	 
	surface.SetDrawColor(crosshairRed, crosshairGreen, crosshairBlue, crosshairAlpha)
	surface.DrawRect(xCenter - crosshairGap - crosshairLength, yCenter - crosshairThicknessHalf, crosshairLength, crosshairThickness)
	surface.DrawRect(xCenter + crosshairGap, yCenter - crosshairThicknessHalf, crosshairLength, crosshairThickness)
	surface.DrawRect(xCenter - crosshairThicknessHalf, yCenter - crosshairGap - crosshairLength, crosshairThickness, crosshairLength)
	surface.DrawRect(xCenter - crosshairThicknessHalf, yCenter + crosshairGap, crosshairThickness, crosshairLength)
	surface.SetDrawColor(255, 255, 255, 255)
end)

-- CGH.GetCoordinates: Get entity's coordinates
function CGH.GetCoordiantes(ent)
    local min, max = ent:OBBMins(), ent:OBBMaxs()
    local corners = {
            Vector( min.x, min.y, min.z ),
            Vector( min.x, min.y, max.z ),
            Vector( min.x, max.y, min.z ),
            Vector( min.x, max.y, max.z ),
            Vector( max.x, min.y, min.z ),
            Vector( max.x, min.y, max.z ),
            Vector( max.x, max.y, min.z ),
            Vector( max.x, max.y, max.z )
    }
     
    local minX, minY, maxX, maxY = ScrW() * 2, ScrH() * 2, 0, 0
    for _, corner in pairs( corners ) do
            local onScreen = ent:LocalToWorld( corner ):ToScreen()
            minX, minY = math.min( minX, onScreen.x ), math.min( minY, onScreen.y )
            maxX, maxY = math.max( maxX, onScreen.x ), math.max( maxY, onScreen.y )
    end

    return minX, minY, maxX, maxY
end

-- Add hook for wall hack
hook.Remove("HUDPaint", "CGH.ESP")
hook.Add("HUDPaint", "CGH.ESP", function()
    if CGH.WallhackEnabled == false then return end
    if !LocalPlayer():Alive() then return end

    -- Loop through all players
    for k,v in pairs(player.GetAll()) do
        -- Check if player is not dead etc.
        if (
            !v:IsDormant() &&
            v:Alive() &&
            v:Health() > 0 &&
            v != LocalPlayer()
        ) then
            local tr = util.TraceLine( {
				start = LocalPlayer():EyePos(),
				endpos = LocalPlayer():EyePos() + (EyeAngles():Forward() * 100000000),
			})

			local Position = ( v:GetPos() + Vector( 0,0,80 ) ):ToScreen()
            if (v:IsAdmin() || table.HasValue({"superadmin", "admin", "helper", "moderator", "helper+", "moderator+"}, v:GetNWString("usergroup"))) then
                -- Don't show admin if convar is not set
                if CGH.WhShowAdminConVar:GetInt() != 1 then continue end
                draw.DrawText( v:Name(), "Default", Position.x, Position.y - 20, Color( 0, 0, 255, 255 ), 1 )
				draw.DrawText( v:Health() .. " " .. v:Armor(), "Default", Position.x, Position.y, Color( 0, 255, 0, 255 ), 1 )
			else
				draw.DrawText( v:Name(), "Default", Position.x, Position.y - 20, Color( 255, 0, 0, 255 ), 1 )
				draw.DrawText( v:Health() .. " " .. v:Armor(), "Default", Position.x, Position.y, Color( 0, 255, 0, 255 ), 1 )
			end

			local x1,y1,x2,y2 = CGH.GetCoordiantes(v)
    
            surface.SetDrawColor(Color(61, 61, 61, 255))
            surface.DrawOutlinedRect(x1, y1, x2-x1, y2-y1, 4)

			if tr.PhysicsBone != 0 and tr.Entity == v then
				surface.SetDrawColor(Color(58, 227, 116, 255))
			else
				surface.SetDrawColor(Color(255, 56, 56, 255))
            end
            
            surface.DrawOutlinedRect(x1, y1, x2-x1, y2-y1, 2)

            surface.SetDrawColor(Color(61, 61, 61, 255))
            surface.DrawOutlinedRect(x1, y1, x2-x1, y2-y1, 1)

            -- Draw health bar
            
            surface.DrawRect(x1 - 20, y1 - 1, 6, y2-y1, 3)
            
            local healthBarLength = y2-y1

            if v:Health() >= 100 then
                surface.SetDrawColor(Color(58, 227, 116, 255)) -- Green
            elseif (v:Health() <= 70 && v:Health() > 40) then
                surface.SetDrawColor(Color(255, 242, 0, 255)) -- Yellow
            else
                surface.SetDrawColor(Color(255, 56, 56, 255)) -- Red
            end

            surface.DrawRect(x1 - 19, y1, 4, healthBarLength)

        end
    end

end)

-- Add hook for recoil
hook.Remove("HUDPaint", "CGH.NR")
hook.Add("HUDPaint", "CGH.NR", function()
	local wep = LocalPlayer():GetActiveWeapon()
    if (wep.Recoil == nil) then return end
    if (type(wep.Recoil) != "function") then return end
    if (debug.getinfo(wep.Recoil)["short_src"] != CGH.RecoilFuncPath) then return end

    local orgRecoil = wep.Recoil
    wep.Recoil = function (recoil, ifp)
        if CGH.NoRecoilEnabled == true then
            LocalPlayer():ViewPunchReset()
            return
        end

        orgRecoil(recoil, ifp)
        return
    end
end)

-- Open menu with INSERT key
hook.Remove("Think", "CGH.MENU")
hook.Add("Think", "CGH.MENU", function()
    if input.IsKeyDown(KEY_INSERT) and not MenuDelay then
        MenuDelay = true
        CGH:OpenMenu()

        timer.Simple(0.5, function()
            MenuDelay = false
        end)
    end
end)




