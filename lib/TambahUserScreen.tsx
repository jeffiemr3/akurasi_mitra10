import React, { useState } from 'react';
import { ArrowLeft, UserPlus, CheckCircle2 } from 'lucide-react';
import { AppUser, UserRole } from '../types';

interface TambahUserScreenProps {
  categories: string[];
  onBack: () => void;
  onAddUser: (user: Omit<AppUser, 'id'>) => void;
}

export const TambahUserScreen: React.FC<TambahUserScreenProps> = ({
  categories,
  onBack,
  onAddUser,
}) => {
  const [name, setName] = useState('');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState<UserRole>('client');
  const [category, setCategory] = useState<string>(categories[0] || 'Floring & Wall');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !username.trim() || !password.trim()) {
      setError('Semua kolom bertanda wajib diisi');
      return;
    }

    onAddUser({
      name: name.trim(),
      username: username.trim().toLowerCase(),
      password: password.trim(),
      role,
      category: role === 'admin' ? null : category,
      status: 'active',
    });

    setSuccess(true);
    setTimeout(() => {
      onBack();
    }, 1200);
  };

  return (
    <div className="min-h-screen bg-[#DCE7F7] flex flex-col p-4 sm:p-6">
      <div className="w-full max-w-[520px] mx-auto flex flex-col flex-1">
        {/* Header */}
        <div className="flex items-center gap-3 mb-3">
          <button
            id="btn-tambah-user-back"
            onClick={onBack}
            className="w-8 h-8 rounded-full bg-white border border-[#DDE4F0] flex items-center justify-center text-[#172554] hover:bg-gray-50"
          >
            <ArrowLeft size={16} />
          </button>
          <span className="text-[12px] font-bold tracking-wider text-[#5B688A] uppercase">
            TAMBAH USER
          </span>
        </div>

        {/* Card */}
        <div className="bg-white rounded-[28px] p-6 sm:p-8 flex-1 flex flex-col shadow-sm">
          <div>
            <h1 className="text-[20px] font-bold text-[#172554]">Tambah User Baru</h1>
            <p className="text-[12px] text-[#5B688A] mt-0.5">
              Buat akun auditor atau administrator baru
            </p>
          </div>

          <form onSubmit={handleSubmit} className="mt-6 space-y-4 flex-1">
            {/* Full Name */}
            <div>
              <label className="block text-[12px] font-medium text-[#5B688A] mb-1">
                Nama Lengkap *
              </label>
              <input
                type="text"
                placeholder="Misal: Sahat Sinaga"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full px-3.5 py-2.5 bg-[#F4F7FC] border border-[#DDE4F0] rounded-xl text-[13.5px] focus:outline-none focus:border-[#16225C]"
              />
            </div>

            {/* Username */}
            <div>
              <label className="block text-[12px] font-medium text-[#5B688A] mb-1">
                Username *
              </label>
              <input
                type="text"
                placeholder="Misal: sahat.sinaga"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                className="w-full px-3.5 py-2.5 bg-[#F4F7FC] border border-[#DDE4F0] rounded-xl text-[13.5px] focus:outline-none focus:border-[#16225C]"
              />
            </div>

            {/* Password */}
            <div>
              <label className="block text-[12px] font-medium text-[#5B688A] mb-1">
                Kata Sandi *
              </label>
              <input
                type="password"
                placeholder="Masukkan kata sandi"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-3.5 py-2.5 bg-[#F4F7FC] border border-[#DDE4F0] rounded-xl text-[13.5px] focus:outline-none focus:border-[#16225C]"
              />
            </div>

            {/* Role Radio */}
            <div>
              <label className="block text-[12px] font-medium text-[#5B688A] mb-1">
                Role Akses
              </label>
              <div className="grid grid-cols-2 gap-3">
                <label
                  className={`p-3 border rounded-xl flex items-center gap-2 cursor-pointer text-[13px] font-semibold ${
                    role === 'client'
                      ? 'border-[#16225C] bg-[#E5E8F5] text-[#16225C]'
                      : 'border-[#DDE4F0] text-[#5B688A]'
                  }`}
                >
                  <input
                    type="radio"
                    name="role"
                    value="client"
                    checked={role === 'client'}
                    onChange={() => setRole('client')}
                    className="accent-[#16225C]"
                  />
                  Auditor Client
                </label>

                <label
                  className={`p-3 border rounded-xl flex items-center gap-2 cursor-pointer text-[13px] font-semibold ${
                    role === 'admin'
                      ? 'border-[#16225C] bg-[#E5E8F5] text-[#16225C]'
                      : 'border-[#DDE4F0] text-[#5B688A]'
                  }`}
                >
                  <input
                    type="radio"
                    name="role"
                    value="admin"
                    checked={role === 'admin'}
                    onChange={() => setRole('admin')}
                    className="accent-[#16225C]"
                  />
                  Admin Store
                </label>
              </div>
            </div>

            {/* Category selection if Client */}
            {role === 'client' && (
              <div>
                <label className="block text-[12px] font-medium text-[#5B688A] mb-1">
                  Kategori Utama
                </label>
                <select
                  value={category}
                  onChange={(e) => setCategory(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-[#F4F7FC] border border-[#DDE4F0] rounded-xl text-[13.5px] text-[#172554] focus:outline-none focus:border-[#16225C]"
                >
                  {categories.map((cat) => (
                    <option key={cat} value={cat}>
                      {cat}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {error && (
              <p className="text-[12px] font-medium text-[#B3131A]">{error}</p>
            )}

            {success && (
              <div className="p-3 bg-[#E1F5EE] text-[#0F6E56] rounded-xl text-[13px] font-medium flex items-center gap-2">
                <CheckCircle2 size={16} /> User berhasil didaftarkan!
              </div>
            )}

            <div className="pt-4">
              <button
                type="submit"
                className="w-full bg-[#16225C] hover:bg-[#1F2E75] text-white py-3.5 rounded-full text-[14px] font-semibold transition-colors"
              >
                Simpan User
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};
