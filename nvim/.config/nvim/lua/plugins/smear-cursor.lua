return {
   "sphamba/smear-cursor.nvim",
   event = "VeryLazy",
   opts = {
      stiffness = 0.9,
      trailing_stiffness = 0.5,
      distance_stop_animating = 0.5,
      smear_to_cmd = false,
      particles_enabled = true,
      never_draw_over_target = true,
      particles_max_num = 300,
      paricles_per_second = 300,
      particle_spread = 0.75,
      min_distance_emit_particles = 3,
   },
}
