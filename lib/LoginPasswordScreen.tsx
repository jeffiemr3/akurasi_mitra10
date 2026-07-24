import React, { useState } from 'react';
import { ArrowLeft, Eye, EyeOff } from 'lucide-react';
import { Badge } from '../components/Badge';
import { AppUser } from '../types';

interface LoginPasswordScreenProps {
  username: string;
  users: AppUser[];
  onBack: () => void;
  onLoginSuccess: (user: AppUser) => void;
}

export const LoginPasswordScreen: React.FC<LoginPasswordScreenProps> = ({
  username,
  users,
  onBack,
  onLoginSuccess,
}) => {
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!password) {
      setError('Kata sandi wajib diisi');
      return;
    }

    // Find user in database
    const user = users.find(
      (u) => u.username.toLowerCase() === username.toLowerCase()
    );

    if (!user) {
      setError('User tidak ditemukan. Coba akun "admin" dengan kata sandi "admin"');
      return;
    }

    if (user.password !== password) {
      setError('Kata sandi salah. Coba lagi.');
      return;
    }

    setError('');
    onLoginSuccess(user);
  };

  return (
    <div className="min-h-screen bg-[#DCE7F7] flex flex-col p-6">
      <div className="flex items-center gap-2">
        <button
          id="btn-password-back"
          type="button"
          onClick={onBack}
          className="w-8 h-8 rounded-full bg-white border border-[#DDE4F0] flex items-center justify-center text-[#172554] hover:bg-gray-50"
        >
          <ArrowLeft size={16} />
        </button>
        <span className="text-[12px] font-bold tracking-wider text-[#5B688A] uppercase">
          MASUK
        </span>
      </div>

      <div className="flex-1 flex items-center justify-center py-6">
        <div className="w-full max-w-[400px] bg-white rounded-[28px] p-8 shadow-sm">
          <form onSubmit={handleSubmit} className="flex flex-col items-center text-center">
            <Badge />
            <span className="text-[11px] font-bold tracking-[2px] text-[#F5B301] mt-4 uppercase">
              MITRA10
            </span>
            <h1 className="text-[26px] font-bold text-[#172554] mt-1">
              Kata Sandi
            </h1>
            <p className="text-[13px] text-[#5B688A] leading-relaxed mt-1">
              Masukkan kata sandi untuk akun <span className="font-semibold text-[#16225C]">@{username}</span>
            </p>

            <div className="w-full text-left mt-6">
              <label htmlFor="password-input" className="block text-[12px] text-[#5B688A] mb-1.5 font-medium">
                Kata sandi
              </label>
              <div className="relative">
                <input
                  id="password-input"
                  type={showPassword ? 'text' : 'password'}
                  placeholder="Masukkan kata sandi"
                  value={password}
                  onChange={(e) => {
                    setPassword(e.target.value);
                    if (error) setError('');
                  }}
                  className={`w-full pl-3.5 pr-10 py-3 bg-[#F4F7FC] border rounded-xl text-[14px] text-[#172554] focus:outline-none transition-colors ${
                    error ? 'border-[#B3131A]' : 'border-[#DDE4F0] focus:border-[#16225C]'
                  }`}
                  autoFocus
                />
                <button
                  id="btn-toggle-password"
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-[#5B688A] hover:text-[#172554]"
                >
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
              {error && (
                <span id="password-error-msg" className="block text-[11.5px] text-[#B3131A] mt-1.5 font-medium">
                  {error}
                </span>
              )}
            </div>

            <button
              id="btn-login-submit"
              type="submit"
              className="w-full mt-6 bg-[#16225C] hover:bg-[#1F2E75] text-white py-3.5 rounded-full text-[15px] font-semibold transition-colors shadow-sm"
            >
              Masuk
            </button>

            <div className="mt-5 p-3 bg-[#EAEEF6] rounded-xl text-[11.5px] text-[#5B688A] text-left w-full">
              <span className="font-semibold text-[#172554]">Akun Pengujian Demo:</span>
              <ul className="list-disc list-inside mt-1 space-y-0.5">
                <li><strong>Admin:</strong> admin / admin</li>
                <li><strong>Auditor:</strong> sahat.sinaga / rahasia123</li>
                <li><strong>Auditor:</strong> jeffie / 123456</li>
              </ul>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};
