const rl = @import("raylib.zig");

const GLSL_VERSION: c_int = 330;
const screenWidth: c_int = 800;
const screenHeight: c_int = 451;

pub fn main() void {
    // Initialization
    //--------------------------------------------------------------------------------------

    rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT); // Enable Multi Sampling Anti Aliasing 4x (if available)
    rl.InitWindow(screenWidth, screenHeight, "raylib [shaders] example - basic lighting");

    // Define the camera to look into our 3d world
    var camera = rl.Camera{
        .position = rl.Vector3{ .x = 2.0, .y = 4.0, .z = 6.0 },
        .target = rl.Vector3{ .x = 0.0, .y = 0.5, .z = 0.0 },
        .up = rl.Vector3{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .fovy = 45.0,
        .projection = rl.CAMERA_PERSPECTIVE,
    };
    // Load basic lighting shader
    const shader = rl.LoadShader(rl.TextFormat("./resources/shaders/glsl%i/lighting.vs", GLSL_VERSION), rl.TextFormat("./resources/shaders/glsl%i/lighting.fs", GLSL_VERSION));
    // Get some required shader locations
    shader.locs[rl.SHADER_LOC_VECTOR_VIEW] = rl.GetShaderLocation(shader, "viewPos");
    // NOTE: "matModel" location name is automatically assigned on shader loading,
    // no need to get the location again if using that uniform name
    // shader.locs[rl.SHADER_LOC_MATRIX_MODEL] = rl.GetShaderLocation(shader, "matModel");

    // Ambient light level (some basic lighting)
    const ambientLoc = rl.GetShaderLocation(shader, "ambient");
    rl.SetShaderValue(shader, ambientLoc, &[4]f32{ 0.1, 0.1, 0.1, 1.0 }, rl.SHADER_UNIFORM_VEC4);

    // Create lights
    var lights = [rl.MAX_LIGHTS]rl.Light{
        rl.CreateLight(rl.LIGHT_POINT, rl.Vector3{ .x = -2, .y = 1, .z = -2 }, rl.Vector3Zero(), rl.YELLOW, shader),
        rl.CreateLight(rl.LIGHT_POINT, rl.Vector3{ .x = 2, .y = 1, .z = 2 }, rl.Vector3Zero(), rl.RED, shader),
        rl.CreateLight(rl.LIGHT_POINT, rl.Vector3{ .x = -2, .y = 1, .z = 2 }, rl.Vector3Zero(), rl.GREEN, shader),
        rl.CreateLight(rl.LIGHT_POINT, rl.Vector3{ .x = 2, .y = 1, .z = -2 }, rl.Vector3Zero(), rl.BLUE, shader),
    };

    rl.SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    const cube = rl.LoadModelFromMesh(rl.GenMeshCube(2.0, 4.0, 2.0));
    cube.materials[0].shader = shader;

    const plane = rl.LoadModelFromMesh(rl.GenMeshCube(10.0, 0.1, 10.0));
    plane.materials[0].shader = shader;

    // Main game loop
    while (!rl.WindowShouldClose()) // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        rl.UpdateCamera(&camera, rl.CAMERA_ORBITAL);

        // Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
        const cameraPos = [3]f32{ camera.position.x, camera.position.y, camera.position.z };
        rl.SetShaderValue(shader, shader.locs[rl.SHADER_LOC_VECTOR_VIEW], &cameraPos, rl.SHADER_UNIFORM_VEC3);

        // Check key inputs to enable/disable lights
        if (rl.IsKeyPressed(rl.KEY_Y)) lights[0].enabled = !lights[0].enabled;
        if (rl.IsKeyPressed(rl.KEY_R)) lights[1].enabled = !lights[1].enabled;
        if (rl.IsKeyPressed(rl.KEY_G)) lights[2].enabled = !lights[2].enabled;
        if (rl.IsKeyPressed(rl.KEY_B)) lights[3].enabled = !lights[3].enabled;

        // Update light values (actually, only enable/disable them)
        for (0..rl.MAX_LIGHTS) |i| rl.UpdateLightValues(shader, lights[i]);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.BeginDrawing();

        rl.ClearBackground(rl.RAYWHITE);

        rl.BeginMode3D(camera);

        rl.BeginShaderMode(shader);

        rl.DrawModel(cube, rl.Vector3Zero(), 1.0, rl.WHITE);
        rl.DrawModel(plane, rl.Vector3Zero(), 1.0, rl.WHITE);

        rl.EndShaderMode();

        // Draw spheres to show where the lights are
        for (0..rl.MAX_LIGHTS) |i| {
            if (lights[i].enabled) {
                rl.DrawSphereEx(lights[i].position, 0.2, 8, 8, lights[i].color);
            } else {
                rl.DrawSphereWires(lights[i].position, 0.2, 8, 8, rl.ColorAlpha(lights[i].color, 0.3));
            }
        }

        rl.DrawGrid(10, 1.0);

        rl.EndMode3D();

        rl.DrawFPS(10, 10);

        rl.DrawText("Use keys [Y][R][G][B] to toggle lights", 10, 40, 20, rl.DARKGRAY);

        rl.EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    rl.UnloadShader(shader); // Unload shader

    rl.CloseWindow(); // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
