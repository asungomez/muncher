import { Outlet } from "react-router";
import Footer from "../components/Footer/Footer";
import Navbar from "../components/Navbar/Navbar";

/** The shell every page renders inside: papered background, navbar and footer. */
function Layout() {
  return (
    <div
      className="min-h-screen bg-paper-stock"
      style={{
        backgroundImage: "url('/page_background.png')",
        backgroundRepeat: "repeat",
        backgroundSize: "650px auto",
        backgroundPosition: "center",
      }}
    >
      <Navbar />
      <main className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <Outlet />
      </main>
      <Footer />
    </div>
  );
}

export default Layout;
