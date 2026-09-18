import { createBrowserRouter, RouterProvider } from "react-router";
import Home from "../pages/Home/Home";
import Layout from "./Layout";

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

/** The application's router. */
function Routes() {
  return <RouterProvider router={router} />;
}

export default Routes;
