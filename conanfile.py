from conan import ConanFile
from conan.tools.cmake import CMakeDeps, CMakeToolchain

class PALRecipe(ConanFile):
    settings = "os", "build_type"
    
    def requirements(self):
        pass
        self.requires("boost/1.83.0")
        # self.requires("vtk/9.4.1")
        # self.requires("assimp/5.4.2")
        # self.requires("zlib/1.3.1")
        
    def generate(self):
        tc = CMakeToolchain(self)
        tc.user_presets_path = False
        tc.generate()
        cd = CMakeDeps(self)
        cd.generate()