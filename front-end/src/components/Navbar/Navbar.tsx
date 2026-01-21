import { NavLink } from "react-router";

function Navbar() {
  return (
    <nav className="bg-white w-full shadow-sm">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-2">
        <div className="flex items-center">
          <NavLink to="/">
            <img src="/muncher_logo.png" alt="Muncher logo" className="h-12" />
          </NavLink>
        </div>
      </div>
    </nav>
  );
}

export default Navbar;
