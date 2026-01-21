import { createBrowserRouter, RouterProvider, Outlet } from "react-router";
import Home from "../pages/Home/Home";
import Navbar from "../components/Navbar/Navbar";

function Layout() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      <main className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <Outlet />
      </main>
    </div>
  );
}

const router = createBrowserRouter([
  {
    element: <Layout />,
    children: [
      {
        path: "/",
        element: <Home />,
      },
    ],
  },
]);

function Routes() {
  return <RouterProvider router={router} />;
}

export default Routes;
