
local T = {}

function T.muiltipy (v1, multi)
    return T(v1.x * multi, v1.y * multi)
end


-- gets the middle between points

function T:sub (v1, v2)
    return T(v1.x -v2.x, v1.y - v2.y)
end

-- dot product compares two vectors (length, angle, ect [specifically just length and height for this one])
function T:dotProd (v)

    return self.x * v.x + self.y * v.y

end


-- edge normal is a vector perpendicular to a shape edge (goes 90* from the edge)
function T:Normal ()
    return T(self.y, -self.x)
end

-- circle X rectangle collision

function T:CircRect(c, radius, r, RW, RH)

    local closX = math.max(r.x, math.min(c.x, r.x + RW))
    local closY = math.max(r.y, math.min(c.y, r.y + RH))

    local disX = c.x - closX
    local disY = c.y - closY

    local dis3 = disX^2 + disY^2


    return dis3 < c.radius^2
end

-- rectangle x rectangle collision

function T.AABB(x1, y1, w1, h1, x2, y2, w2, h2)

    if x1 == nil then
        return "x1 = nil"
    elseif y1 == nil then
        return "y1 = nil"
    elseif w1 == nil then
        return "w1 = nil"
    elseif h1 == nil then
        return "h1 = nil"
    elseif x2 == nil then
        return "x2 = nil"
    elseif y2 == nil then
        return "y2 = nil"
    elseif w2 == nil then
        return "w2 = nil"
    elseif h2 == nil then
        return "h2 = nil"
    end


    return x1 < x2 + w2 and
    x2 < x1 + w1 and
    y1 < y2 + h2 and
    y2 < y1 + h1

end

--Seperating Axis Therom (SAT)


--gets all the edge normals from a 2d (obviously) shape

local function getNormals(vert)

    -- vert = verticies
    if vert == nil or #vert == 0 then return nil end

    local normals = {}

    for i = 1, #vert do

        --p1 and 2 represent vertexs

        local p1 = v[i]
        local p2 = v[i + 1] or v[1]

        --getting normal

        local middle = T:sub(p1, p2)

        local edgenorm = middle:Normal()

        --gets the direction of where the colliding object should go to stop colliding

        edgenorm:unit()

        normals[#normals + 1] = edgenorm

    end

    return normals
end

--projects the given verticies onto the given axis

local function project (v, a)
    local min = a:dotProd(v[1])
    local max = min

    for i = 2, #v do 
        local proj = a:dotProd(v[i])

        if proj < min then min = proj
        elseif proj > max then max = proj
        end
    end

    return min, max
end

-- does SAT on given polygons
-- if true and returns the minimum seperation vector then its colliding

-- if false/nil vector then not colliding

function T.SAT (p1, p2)

    --p1 and 2 represent polygons

    local axis1 = getNormals(p1)
    local axis2 = getNormals(p2)
    local overlap = 9999999999999999
    local minPenetration = nil

    --  connect axis 2 into axis 1

    for i = 1, #axis2 do axis1[#axis1 + 1] = axis2[i] end


    --projecting shapes onto the seperation axis to check

    for i = 1, #axis1 do 
        local axis = axis1[i]

        local p1min, p1max = project(p1, axis)
        local p2min, p2max = project(p2, axis)

        --checking for overlap nil = no overlap

        if p1min > p2max or p2min > p1max then return nil, nil end
        -- otherwise will check the amount of overlap

        local o = math.min(p1max, p2max) - math.max(p1min, p2min)

        if o < overlap then 
        overlap = o
        minPenetration = axis
        end
        
        

    end


    --if this hasn't ended by this point, the shapes are colliding

    return minPenetration, overlap
end

--converts tables into vector 2s (dont use this it doesnt work. missing vector2 function)

--function T.table2Vector2 (table)
  --  local vert = {}

    --checks if the table has an even # of things in it
  --  assert(#table % 2 == 0, "table must have an even number of elements") 

  --  for i = 1, #table, 2 do
   --     vert[#vert + 1]


  --  end



 --   return vert
--end


return T