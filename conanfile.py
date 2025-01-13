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
        self.requires("catch2/2.13.10")
        self.requires("nanosvg/fltk.20221222")
        self.requires("libbgcode/20241001")
        self.requires("cgal/5.6.1")
        self.requires("cereal/1.3.0")
        self.requires("expat/2.6.2")
        self.requires("qhull/8.1.0")
        self.requires("wxwidgets/3.2.5")
        self.requires("libcurl/8.9.1")
        self.requires("openvdb/11.0.0")
        self.requires("opencascade/7.6.0")

    def generate(self):
        tc = CMakeToolchain(self)
        tc.user_presets_path = False
        tc.generate()
        cd = CMakeDeps(self)
        cd.generate()