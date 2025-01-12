from conan import ConanFile
from conan.tools.cmake import CMakeDeps, CMakeToolchain

class PALRecipe(ConanFile):
    settings = "os", "build_type"
    
    def requirements(self):
        pass
        self.requires("boost/1.83.0")
        self.requires("eigen/3.4.0")
        self.requires("nlopt/2.7.1")
        self.requires("onetbb/2021.10.0")
        self.requires("libpng/1.6.43")
        self.requires("libjpeg-turbo/3.0.2")
        self.requires("glew/2.2.0")
        self.requires("catch2/3.7.0")
        self.requires("nanosvg/cci.20231025")
        self.requires("libbgcode/20241001")
        # self.requires("vtk/9.4.1")
        # self.requires("assimp/5.4.2")
        # self.requires("zlib/1.3.1")
        
    def generate(self):
        tc = CMakeToolchain(self)
        tc.user_presets_path = False
        tc.generate()
        cd = CMakeDeps(self)
        cd.generate()